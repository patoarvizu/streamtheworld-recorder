module "c2019" {
  source = "../../modules/stwr-scheduled-season"
  schedule = "${local.liguilla_a2019_schedule}"
}

module "final_ida_previa_d99" {
  source = "../../modules/stwr-scheduled-event"
  name = "previa-d99-final-ida-monterrey-vs-america"
  cron_expression = "30 23 26 DEC ? 2019"
  call_signal = "D99"
  time_length = "7200"
}

module "final_ida_rg690" {
  source = "../../modules/stwr-scheduled-event"
  name = "rg690-final-ida-monterrey-vs-america"
  cron_expression = "30 2 27 DEC ? 2019"
  call_signal = "RG690"
  time_length = "8100"
}

module "final_vuelta_rg690" {
  source = "../../modules/stwr-scheduled-event"
  name = "rg690-final-vuelta-monterrey-vs-america"
  cron_expression = "0 2 30 DEC ? 2019"
  call_signal = "RG690"
  time_length = "14400"
}