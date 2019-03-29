resource "aws_cloudwatch_event_rule" "stwr_event_rules" {
  count = "${length(keys(var.schedule))}"
  name = "${element(keys(var.schedule), count.index)}"
  schedule_expression = "cron(${lookup(var.schedule, element(keys(var.schedule), count.index))})"
  is_enabled = "true"
}

resource "aws_cloudwatch_event_target" "stwr_scheduled_tasks" {
  count = "${length(keys(var.schedule))}"
  rule = "${element(aws_cloudwatch_event_rule.stwr_event_rules.*.name, count.index)}"
  target_id = "${element(keys(var.schedule), count.index)}"
  arn = "${data.terraform_remote_state.stwr.ecs_cluster_arn}"
  input = "${element(data.template_file.scheduled_tasks.*.rendered, count.index)}"
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