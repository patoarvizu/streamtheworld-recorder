package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/eduncan911/podcast"
)

type podcastConfig struct {
	feedLocation   string
	feedConfigFile string
	s3Bucket       string
	s3KeyToScan    string
	s3Region       string
	s3Endpoint     string
	s3DisableSSL   bool
}

type feedConfig struct {
	Name        string `json:"name"`
	URL         string `json:"url"`
	Description string `json:"description"`
	ImageURL    string `json:"imageURL"`
}

var cfg = &podcastConfig{}

func main() {
	fl := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	fl.StringVar(&cfg.feedLocation, "feed-location", "podcast.xml", "Location of the feed starter file.")
	fl.StringVar(&cfg.feedConfigFile, "feed-config-file", "feed-config.json", "The location of the feed configuration file.")
	fl.StringVar(&cfg.s3Bucket, "s3-bucket", "", "S3 bucket to upload recording to.")
	fl.StringVar(&cfg.s3KeyToScan, "s3-key-to-scan", "", "S3 key to scan for files.")
	fl.StringVar(&cfg.s3Region, "s3-region", "us-east-1", "AWS region for S3 uploads.")
	fl.StringVar(&cfg.s3Endpoint, "s3-endpoint", "https://s3.amazonaws.com", "S3-compatible endpoint for file downloads.")
	fl.BoolVar(&cfg.s3DisableSSL, "s3-disable-ssl", false, "Disable SSL for the S3 endpoint.")
	fl.Parse(os.Args[1:])

	awsSession := session.Must(session.NewSession(&aws.Config{
		Region:           aws.String(cfg.s3Region),
		Endpoint:         aws.String(cfg.s3Endpoint),
		S3ForcePathStyle: aws.Bool(true),
		DisableSSL:       aws.Bool(cfg.s3DisableSSL),
	}))
	buff := &aws.WriteAtBuffer{}
	uploader := s3manager.NewUploader(awsSession)
	downloader := s3manager.NewDownloader(awsSession)
	_, err := downloader.Download(buff, &s3.GetObjectInput{
		Bucket: aws.String(cfg.s3Bucket),
		Key:    aws.String(cfg.feedConfigFile),
	})
	var feed feedConfig
	if err != nil {
		if err.(awserr.RequestFailure).StatusCode() == 404 {
			fmt.Println("Config file not found, creating new one.")
			feed = feedConfig{
				Name:        "Podcast",
				URL:         "https://podcast.com",
				Description: "Podcast",
				ImageURL:    "",
			}
			b, _ := json.MarshalIndent(feed, "", "  ")
			_, err = uploader.Upload(&s3manager.UploadInput{
				Bucket: aws.String(cfg.s3Bucket),
				Key:    aws.String(cfg.feedConfigFile),
				Body:   strings.NewReader(string(b)),
			})
			if err != nil {
				fmt.Println("Error creating config file, continuing anyway.")
			}
		} else {
			panic(err)
		}
	} else {
		err = json.Unmarshal(buff.Bytes(), &feed)
		if err != nil {
			fmt.Println("Error unmarshaling feed config file.")
			panic(err)
		}
	}
	now := time.Now()
	p := podcast.New(
		feed.Name,
		feed.URL,
		feed.Description,
		&now,
		&now,
	)
	p.AddImage(feed.ImageURL)
	s3Svc := s3.New(awsSession)
	r, err := s3Svc.ListObjectsV2(&s3.ListObjectsV2Input{
		Bucket: aws.String(cfg.s3Bucket),
		Prefix: aws.String(cfg.s3KeyToScan),
	})
	if err != nil {
		panic(err)
	}
	items := make([]*podcast.Item, 0)
	for _, o := range r.Contents {
		if strings.HasSuffix(*o.Key, ".mp3") {
			item := &podcast.Item{
				Title:       filepath.Base(strings.TrimSuffix(*o.Key, ".mp3")),
				Description: filepath.Base(strings.TrimSuffix(*o.Key, ".mp3")),
				PubDate:     o.LastModified,
			}
			item.AddEnclosure(fmt.Sprintf("%s/%s/%s", cfg.s3Endpoint, cfg.s3Bucket, *o.Key), podcast.MP3, *o.Size)
			items = append(items, item)
		}
	}
	sort.Slice(items, func(i, j int) bool {
		return items[i].PubDate.Before(*items[j].PubDate)
	})
	p.Items = items
	_, err = uploader.Upload(&s3manager.UploadInput{
		Bucket: aws.String(cfg.s3Bucket),
		Key:    aws.String(cfg.feedLocation),
		Body:   strings.NewReader(p.String()),
	})
	if err != nil {
		panic(err)
	}
}
