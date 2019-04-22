terraform {
  backend "s3" {
    bucket  = "patoarvizu-terraform-states"
    key     = "streamtheworld-recorder/schedules/concacaf-2019/terraform.tfstate"
    region  = "us-east-1"
    profile = "patoarvizu-admin"
  }
}