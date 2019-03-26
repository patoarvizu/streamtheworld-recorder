resource "aws_iam_role" "stwr_task" {
  name = "stwr-task-ecs"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "s3_access" {
  name = "stwr-recordings"
  role = "${aws_iam_role.stwr_task.name}"
  policy = "${data.aws_iam_policy_document.stwr_recordings_bucket.json}"
}

resource "aws_iam_role" "stwr_execution" {
  name = "swtr-execution-ecs"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_tasks_assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role = "${aws_iam_role.stwr_execution.name}"
}

resource "aws_iam_role" "stwr_events" {
  name = "stwr-events-ecs"
  assume_role_policy = "${data.aws_iam_policy_document.events_assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_events" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
  role = "${aws_iam_role.stwr_events.name}"
}