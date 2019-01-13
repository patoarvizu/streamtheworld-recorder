module "j3" {
  source = "../../modules/stwr-scheduled-event"
  name = "tigres-vs-cruz-azul-j3"
  cron_expression = "0 2 20 JAN ? 2019"
  call_signal = "D99"
  time_length = "11700"
}