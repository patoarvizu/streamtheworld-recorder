data "terraform_remote_state" "stwr" {
  backend = "s3"
  config {
    bucket  = "patoarvizu-terraform-states"
    key     = "streamtheworld-recorder/eks/terraform.tfstate"
    region  = "us-east-1"
    profile = "patoarvizu-admin"
  }
}