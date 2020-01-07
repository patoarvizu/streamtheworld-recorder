terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "patoarvizu"
    workspaces {
      name = "stwr-ecs-liguilla-a2019"
    }
  }
}
