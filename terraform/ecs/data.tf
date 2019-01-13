data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  id = "${local.default_vpc_id}"
}

data "aws_iam_policy_document" "ecr_repo_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage"
    ]
    principals {
      type = "AWS"
      identifiers = [ "${data.aws_caller_identity.current.account_id}" ]
    }
  }
}

data "template_file" "stwr_task_definition" {
  template = "${file("${path.module}/templates/stwr.json.tpl")}"
  vars {
    stwr_repository = "${aws_ecr_repository.stwr.repository_url}"
    stwr_version = "${local.stwr_version}"
    cloudwatch_logs_group = "${aws_cloudwatch_log_group.stwr.name}"
  }
}

data "aws_iam_policy_document" "ecs_tasks_assume_role_policy" {
  statement {
    principals {
      type = "Service"
      identifiers = [ "ecs-tasks.amazonaws.com" ]
    }
    actions = [ "sts:AssumeRole" ]
  }
}

data "aws_iam_policy_document" "events_assume_role_policy" {
  statement {
    principals {
      type = "Service"
      identifiers = [ "events.amazonaws.com" ]
    }
    actions = [ "sts:AssumeRole" ]
  }
}