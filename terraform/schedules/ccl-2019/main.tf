module "final_ida" {
  source = "../../modules/stwr-scheduled-event"
  name = "final-ida-tigres-vs-monterrey"
  cron_expression = "0 1 24 APR ? 2019"
  call_signal = "RG690"
  time_length = "11700"
}

module "final_vuelta" {
  source = "../../modules/stwr-scheduled-event"
  name = "final-vuelta-monterrey-vs-tigres"
  cron_expression = "0 1 2 MAY ? 2019"
  call_signal = "RG690"
  time_length = "14400"
}
