module "c2019" {
  source = "../../modules/stwr-scheduled-season"
  schedule = "${local.a2019_schedule}"
}