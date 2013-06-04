package { "mplayer":
  ensure => installed
}
package { "python":
  ensure => installed
}
package { "mutt":
  ensure => installed
}
package { "tzdata":
  ensure => installed
}
package { "mailutils":
  ensure => installed
}
file { "timezone":
  path => "/etc/timezone",
  content => "America/New_York",
  notify => Exec["set-timezone"]
}
exec { "set-timezone":
  command => "/usr/sbin/dpkg-reconfigure -f noninteractive tzdata",
  require => File["timezone"],
  subscribe => File["timezone"]
}
user { "ubuntu":
  home => "/home/ubuntu",
  ensure => "present"
}
cron { "record-el-despioje-1":
  environment => "MAILTO=ubuntu@localhost",
  command => "/home/ubuntu/streamtheworld-recorder/streamtheworld-scheduled.sh D99 90",
  user => "ubuntu",
  minute => "30",
  hour => "7",
  weekday => ["1-5"]
}
cron { "record-el-despioje-2":
  command => "/home/ubuntu/streamtheworld-recorder/streamtheworld-scheduled.sh D99 60",
  user => "ubuntu",
  minute => "0",
  hour => "9",
  weekday => ["1-5"]
}
cron { "record-el-despioje-3":
  environment => "MAILTO=ubuntu@localhost",
  command => "/home/ubuntu/streamtheworld-recorder/streamtheworld-scheduled.sh D99 60",
  user => "ubuntu",
  minute => "0",
  hour => "10",
  weekday => ["1-5"]
}
file { "gitconfig":
  path => "/home/ubuntu/.gitconfig",
  content => "[user]\n\tname = Pato Arvizu\n\temail = contact@patoarvizu.com"
}