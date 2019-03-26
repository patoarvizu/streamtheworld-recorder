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

module "c2019" {
  source = "../../modules/stwr-scheduled-season"
  schedule = "${local.c2019_schedule}"
}