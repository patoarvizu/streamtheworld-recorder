output "ecs_cluster_arn" {
  value = "${aws_ecs_cluster.stwr.arn}"
}

output "events_role_arn" {
  value = "${aws_iam_role.stwr_events.arn}"
}

output "security_group_id" {
  value = "${aws_security_group.stwr.id}"
}

output "task_definition_arn" {
  value = "${aws_ecs_task_definition.stwr.arn}"
}