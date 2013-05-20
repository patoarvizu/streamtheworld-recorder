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
cron { "record-el-despioje":
  command => "/home/ubuntu/streamtheworld-recorder/streamtheworld-scheduled.sh D99 240",
  user => "ubuntu",
  minute => "0",
  hour => "7",
  weekday => ["1-5"]
}
exec { "set-git-username":
  command => "/usr/bin/git config --global user.name \"Pato Arvizu\"",
}
exec { "set-git-email":
  command => "/usr/bin/git config --global user.email patoarvizu@gmail.com"
}
