module "c2019" {
  source = "../../modules/stwr-scheduled-season"
  schedule = "${local.liguilla_a2019_schedule}"
}