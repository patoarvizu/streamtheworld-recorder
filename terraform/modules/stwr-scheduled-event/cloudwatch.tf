resource "aws_cloudwatch_event_rule" "stwr_event_rule" {
  name = "${var.name}"
  schedule_expression = "cron(${var.cron_expression})"
  is_enabled = "true"
}

resource "aws_cloudwatch_event_target" "stwr_scheduled_task" {
  rule = "${aws_cloudwatch_event_rule.stwr_event_rule.name}"
  target_id = "${var.name}"
  arn = "${data.terraform_remote_state.stwr.ecs_cluster_arn}"
  input = "${data.template_file.scheduled_task.rendered}"
  role_arn = "${data.terraform_remote_state.stwr.events_role_arn}"

  ecs_target {
    launch_type = "FARGATE"
    network_configuration {
      subnets = [ "${data.aws_subnet_ids.default_subnets.ids}" ]
      security_groups = [ "${data.terraform_remote_state.stwr.security_group_id}" ]
      assign_public_ip = true
    }
    platform_version = "LATEST"
    task_count = 1
    task_definition_arn = "${data.terraform_remote_state.stwr.task_definition_arn}"
  }
}