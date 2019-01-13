resource "aws_ecs_cluster" "stwr" {
  name = "stwr"
}

resource "aws_ecs_task_definition" "stwr" {
  family = "stwr"
  container_definitions = "${data.template_file.stwr_task_definition.rendered}"
  task_role_arn = "${aws_iam_role.stwr_task.arn}"
  execution_role_arn = "${aws_iam_role.stwr_execution.arn}"
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  requires_compatibilities = [ "FARGATE" ]
}