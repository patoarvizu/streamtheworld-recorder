terraform {
  backend "s3" {
    bucket  = "patoarvizu-terraform-states"
    key     = "streamtheworld-recorder/ecs/terraform.tfstate"
    region  = "us-east-1"
    profile = "patoarvizu-admin"
  }
}