data "terraform_remote_state" "stwr" {
  backend = "s3"
  config {
    bucket  = "patoarvizu-terraform-states"
    key     = "streamtheworld-recorder/ecs/terraform.tfstate"
    region  = "us-east-1"
    profile = "patoarvizu-admin"
  }
}

data "aws_vpc" "default" {
  id = "${local.default_vpc_id}"
}

data "aws_subnet_ids" "default_subnets" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "template_file" "scheduled_tasks" {
  count = "${length(keys(var.schedule))}"
  template = "${file("${path.module}/templates/stwr-scheduled-task.json.tpl")}"
  vars {
    call_signal = "${local.call_signal}"
    time_length = "${local.time_length}"
    recording_name = "${element(keys(var.schedule), count.index)}"
  }
}