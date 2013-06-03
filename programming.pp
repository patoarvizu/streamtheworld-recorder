cron { "record-el-despioje":
  environment => "MAILTO=ubuntu@localhost",
  command => "/home/ubuntu/streamtheworld-recorder/streamtheworld-scheduled.sh D99 210",
  user => "ubuntu",
  minute => "30",
  hour => "7",
  weekday => ["1-5"]
}