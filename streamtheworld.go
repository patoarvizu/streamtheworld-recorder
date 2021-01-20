package main

import (
	"encoding/xml"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
)

type LiveStreamConfig struct {
	Mountpoints struct {
		Mountpoint struct {
			Servers struct {
				Server []struct {
					Sid   string `xml:"sid,attr"`
					Ip    string `xml:"ip"`
					Ports struct {
						Port []struct {
							Text string `xml:",chardata"`
							Type string `xml:"type,attr"`
						} `xml:"port"`
					} `xml:"ports"`
				} `xml:"server"`
			} `xml:"servers"`
		} `xml:"mountpoint"`
	} `xml:"mountpoints"`
}

type config struct {
	duration      time.Duration
	callSign      string
	recordingName string
	copyToS3      bool
	s3Bucket      string
	s3Key         string
	s3Region      string
	s3Endpoint    string
}

func main() {
	var cfg = &config{}
	fl := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	fl.DurationVar(&cfg.duration, "duration", time.Duration(60*time.Minute), "Recording duration.")
	fl.StringVar(&cfg.callSign, "call-sign", "", "Station call sign.")
	fl.StringVar(&cfg.recordingName, "recording-name", "", "Recording file name (without the .mp3 extension). Defaults to the value of -call-sign.")
	fl.BoolVar(&cfg.copyToS3, "copy-to-s3", false, "Upload to S3 after recoding.")
	fl.StringVar(&cfg.s3Bucket, "s3-bucket", "", "S3 bucket to upload recording to. Only used if -copy-to-s3 is enabled.")
	fl.StringVar(&cfg.s3Key, "s3-key", "", "S3 key (path) to upload recording to. Only used if -copy-to-s3 is enabled.")
	fl.StringVar(&cfg.s3Region, "s3-region", "us-east-1", "AWS region for S3 uploads. Only used if -copy-to-s3 is enabled.")
	fl.StringVar(&cfg.s3Endpoint, "s3-endpoint", "https://s3.amazonaws.com", "S3-compatible endpoint for file uploads. Only used if -copy-to-s3 is enabled.")
	fl.Parse(os.Args[1:])

	r, err := http.Get(fmt.Sprintf("http://playerservices.streamtheworld.com/api/livestream?version=1.5&mount=%s&lang=en", cfg.callSign))
	if err != nil {
		panic(err)
	}
	defer r.Body.Close()
	data, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	streamConfig := LiveStreamConfig{}
	err = xml.Unmarshal(data, &streamConfig)
	if err != nil {
		panic(err)
	}
	err = os.MkdirAll("/tmp/.recordings", 0744)
	if err != nil {
		panic(err)
	}
	var recordingName string
	if len(cfg.recordingName) > 0 {
		recordingName = cfg.recordingName
	} else {
		recordingName = cfg.callSign
	}
	s := streamConfig.Mountpoints.Mountpoint.Servers.Server[0]
	p := s.Ports.Port[0]
	cmd := exec.Command("mplayer", fmt.Sprintf("%s://%s:%s/%s", p.Type, s.Ip, p.Text, "D99"), "-forceidx", "-dumpstream", "-dumpfile", fmt.Sprintf("/tmp/.recordings/%s.mp3", recordingName))
	err = cmd.Start()
	if err != nil {
		panic(err)
	}
	done := make(chan error, 1)
	go func() {
		done <- cmd.Wait()
	}()
	select {
	case <-time.After(cfg.duration):
		err = cmd.Process.Signal(os.Interrupt)
		if err != nil {
			fmt.Printf("Error interrupting command: %v", err)
			panic(err)
		}
	case err = <-done:
		if err != nil {
			fmt.Printf("Command finished with error: %v", err)
			panic(err)
		}
	}
	if cfg.copyToS3 {
		awsSession := session.Must(session.NewSession(&aws.Config{
			Region:           aws.String(cfg.s3Region),
			Endpoint:         aws.String(cfg.s3Endpoint),
			S3ForcePathStyle: aws.Bool(true),
		}))
		uploader := s3manager.NewUploader(awsSession)
		f, err := os.Open(fmt.Sprintf("/tmp/.recordings/%s.mp3", recordingName))
		if err != nil {
			fmt.Printf("Error opening file: %v", err)
			panic(err)
		}
		result, err := uploader.Upload(&s3manager.UploadInput{
			Bucket: aws.String(cfg.s3Bucket),
			Key:    aws.String(fmt.Sprintf("%s/%s.mp3", cfg.s3Key, recordingName)),
			Body:   f,
		})
		if err != nil {
			fmt.Printf("Error uploading file: %v", err)
			panic(err)
		}
		fmt.Printf("File uploaded to, %s\n", result.Location)
	}
}
