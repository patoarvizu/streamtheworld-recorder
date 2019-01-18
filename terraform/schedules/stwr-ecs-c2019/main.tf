module "j3" {
  source = "../../modules/stwr-scheduled-event"
  name = "tigres-vs-cruz-azul-j3"
  cron_expression = "0 2 20 JAN ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j4" {
  source = "../../modules/stwr-scheduled-event"
  name = "monterrey-vs-america-j4"
  cron_expression = "0 22 26 JAN ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j5" {
  source = "../../modules/stwr-scheduled-event"
  name = "tigres-vs-santos-j5"
  cron_expression = "0 0 3 FEB ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j6" {
  source = "../../modules/stwr-scheduled-event"
  name = "monterrey-vs-lobos-j6"
  cron_expression = "0 9 22 FEB ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j7" {
  source = "../../modules/stwr-scheduled-event"
  name = "tigres-vs-necaxa-j7"
  cron_expression = "0 0 17 FEB ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j8" {
  source = "../../modules/stwr-scheduled-event"
  name = "monterrey-vs-puebla-j8"
  cron_expression = "0 0 24 FEB ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j9" {
  source = "../../modules/stwr-scheduled-event"
  name = "tigres-vs-pachuca-j9"
  cron_expression = "0 0 3 MAR ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j10" {
  source = "../../modules/stwr-scheduled-event"
  name = "monterrey-vs-tigres-j10"
  cron_expression = "0 0 10 MAR ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j11" {
  source = "../../modules/stwr-scheduled-event"
  name = "tigres-vs-queretaro-j11"
  cron_expression = "0 0 17 MAR ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j12" {
  source = "../../modules/stwr-scheduled-event"
  name = "monterrey-vs-cruz-azul-j12"
  cron_expression = "0 2 31 MAR ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j13" {
  source = "../../modules/stwr-scheduled-event"
  name = "tigres-vs-pumas-j13"
  cron_expression = "0 0 7 APR ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j14" {
  source = "../../modules/stwr-scheduled-event"
  name = "monterrey-vs-santos-j14"
  cron_expression = "0 1 14 APR ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j15" {
  source = "../../modules/stwr-scheduled-event"
  name = "tigres-vs-morelia-j15"
  cron_expression = "0 23 20 APR ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j16" {
  source = "../../modules/stwr-scheduled-event"
  name = "monterrey-vs-necaxa-j16"
  cron_expression = "0 23 27 APR ? 2019"
  call_signal = "D99"
  time_length = "11700"
}

module "j17" {
  source = "../../modules/stwr-scheduled-event"
  name = "tigres-vs-chivas-j17"
  cron_expression = "0 23 4 MAY ? 2019"
  call_signal = "D99"
  time_length = "11700"
}