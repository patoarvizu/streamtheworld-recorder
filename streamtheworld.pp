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
