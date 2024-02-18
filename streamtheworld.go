package main

import (
	"encoding/xml"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/iFaceless/godub"
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
	startTime     string
	callSign      string
	recordingName string
	copyToS3      bool
	s3Bucket      string
	s3Key         string
	s3Region      string
	s3Endpoint    string
	s3DisableSSL  bool
	enableStdOut  bool
	enableStdErr  bool
}

var cfg = &config{}

func main() {
	fl := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	fl.DurationVar(&cfg.duration, "duration", time.Duration(60*time.Minute), "Recording duration.")
	fl.StringVar(&cfg.startTime, "start-time", time.Now().Format("2006-01-02 15:04 -0700 MST"), "Recording start time.")
	fl.StringVar(&cfg.callSign, "call-sign", "", "Station call sign.")
	fl.StringVar(&cfg.recordingName, "recording-name", "", "Recording file name (without the .mp3 extension). Defaults to the value of -call-sign.")
	fl.BoolVar(&cfg.copyToS3, "copy-to-s3", false, "Upload to S3 after recoding.")
	fl.StringVar(&cfg.s3Bucket, "s3-bucket", "", "S3 bucket to upload recording to. Only used if -copy-to-s3 is enabled.")
	fl.StringVar(&cfg.s3Key, "s3-key", "", "S3 key (path) to upload recording to. Only used if -copy-to-s3 is enabled.")
	fl.StringVar(&cfg.s3Region, "s3-region", "us-east-1", "AWS region for S3 uploads. Only used if -copy-to-s3 is enabled.")
	fl.StringVar(&cfg.s3Endpoint, "s3-endpoint", "https://s3.amazonaws.com", "S3-compatible endpoint for file uploads. Only used if -copy-to-s3 is enabled.")
	fl.BoolVar(&cfg.s3DisableSSL, "s3-disable-ssl", false, "Disable SSL for the S3 endpoint. Only used if -copy-to-s3 is enabled.")
	fl.BoolVar(&cfg.enableStdOut, "enable-stdout", false, "Enable logging stdout.")
	fl.BoolVar(&cfg.enableStdErr, "enable-stderr", false, "Enable logging stderr.")
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
	err = os.MkdirAll("/tmp/.recordings/segments", 0744)
	if err != nil {
		panic(err)
	}
	var recordingName string
	if len(cfg.recordingName) > 0 {
		recordingName = cfg.recordingName
	} else {
		recordingName = cfg.callSign
	}
	startTimeDate, err := time.Parse("2006-01-02 15:04 -0700 MST", cfg.startTime)
	if err != nil {
		panic(err)
	}
	now := time.Now()
	if now.Before(startTimeDate) {
		log.Fatalf("Too early to run. Start time is in the future. Start time: %s, now: %s.", startTimeDate.String(), now.String())
	}
	if startTimeDate.Add(cfg.duration).Before(now) {
		log.Printf("Current time (%s) is later than startTime + duration (%s). Making sure files are copied to S3.", now.String(), startTimeDate.Add(cfg.duration).String())
		if cfg.copyToS3 {
			err = copyToS3(recordingName)
			if err != nil {
				log.Fatalf("Error uploading to S3: %v", err)
			}
			return
		}
		return
	}
	s := streamConfig.Mountpoints.Mountpoint.Servers.Server[0]
	p := s.Ports.Port[0]
	for {
		if startTimeDate.Add(cfg.duration).After(time.Now()) {
			err = runMplayer(p.Type, s.Ip, p.Text, recordingName, startTimeDate)
			if err != nil {
				log.Printf("Error running command: %s. Re-running.", err)
			}
			log.Println("Finished running mplayer")
		} else {
			break
		}
	}
	if cfg.copyToS3 {
		log.Println("Starting S3 upload")
		err = copyToS3(recordingName)
		if err != nil {
			log.Fatalf("Error uploading to S3: %v", err)
		}
	}
}

func runMplayer(portType string, serverIp string, port string, recordingName string, startTimeDate time.Time) error {
	cmd := exec.Command("mplayer", fmt.Sprintf("%s://%s:%s/%s", portType, serverIp, port, cfg.callSign), "-forceidx", "-dumpstream", "-dumpfile", fmt.Sprintf("/tmp/.recordings/segments/%s-%d.mp3", recordingName, time.Now().Unix()))
	if cfg.enableStdOut {
		cmd.Stdout = os.Stdout
	}
	if cfg.enableStdErr {
		cmd.Stderr = os.Stderr
	}
	err := cmd.Start()
	if err != nil {
		return err
	}
	done := make(chan error, 1)
	go func() {
		done <- cmd.Wait()
	}()
	select {
	case <-time.After(time.Until(startTimeDate.Add(cfg.duration))):
		err = cmd.Process.Signal(os.Interrupt)
		return err
	case err = <-done:
		return err
	}
}

func mergeFiles(recordingName string) error {
	files, err := os.ReadDir("/tmp/.recordings/segments")
	if err != nil {
		return err
	}
	loader := godub.NewLoader()
	segmentSlice := []*godub.AudioSegment{}
	for _, v := range files {
		nextSegment, err := loader.Load(fmt.Sprintf("/tmp/.recordings/segments/%s", v.Name()))
		if err != nil {
			return err
		}
		segmentSlice = append(segmentSlice, nextSegment)
	}

	var final *godub.AudioSegment
	if len(segmentSlice) == 0 {
		log.Println("No audio files to upload. Exiting now.")
		return nil
	} else if len(segmentSlice) == 1 {
		final = segmentSlice[0]
	} else {
		final, err = segmentSlice[0].Append(segmentSlice[1:]...)
		if err != nil {
			return err
		}
	}
	return godub.NewExporter(fmt.Sprintf("/tmp/.recordings/%s.mp3", recordingName)).Export(final)
}

func copyToS3(recordingName string) error {
	err := mergeFiles(recordingName)
	if err != nil {
		return err
	}
	awsSession := session.Must(session.NewSession(&aws.Config{
		Region:           aws.String(cfg.s3Region),
		Endpoint:         aws.String(cfg.s3Endpoint),
		S3ForcePathStyle: aws.Bool(true),
		DisableSSL:       aws.Bool(cfg.s3DisableSSL),
	}))
	uploader := s3manager.NewUploader(awsSession)
	_, err = os.Stat(fmt.Sprintf("/tmp/.recordings/%s.mp3", recordingName))
	if !os.IsNotExist(err) {
		f, err := os.Open(fmt.Sprintf("/tmp/.recordings/%s.mp3", recordingName))
		if err != nil {
			log.Printf("Error opening /tmp/.recordings/%s.mp3: %s", recordingName, err)
			log.Println("Continuing with uploading segments")
		} else {
			_, err = uploader.Upload(&s3manager.UploadInput{
				Bucket: aws.String(cfg.s3Bucket),
				Key:    aws.String(fmt.Sprintf("%s/%s.mp3", cfg.s3Key, recordingName)),
				Body:   f,
			})
			if err != nil {
				log.Printf("Error uploading /tmp/.recordings/%s.mp3: %s", recordingName, err)
				log.Println("Continuing with uploading segments")
			}
		}
	}
	_, err = os.Stat("/tmp/.recordings/segments")
	if !os.IsNotExist(err) {
		files, err := os.ReadDir("/tmp/.recordings/segments")
		if err != nil {
			return err
		}
		for _, v := range files {
			f, err := os.Open(fmt.Sprintf("/tmp/.recordings/segments/%s", v.Name()))
			if err != nil {
				log.Printf("Error opening segment file /tmp/.recordings/segments/%s: %s", v.Name(), err)
				log.Println("Skipping...")
				continue
			}
			_, err = uploader.Upload(&s3manager.UploadInput{
				Bucket: aws.String(cfg.s3Bucket),
				Key:    aws.String(fmt.Sprintf("%s/segments/%s/%s", cfg.s3Key, recordingName, v.Name())),
				Body:   f,
			})
			if err != nil {
				log.Printf("Error uploading segment %s: %s", v.Name(), err)
				log.Println("Skipping...")
				continue
			}
		}
	}
	return nil
}
