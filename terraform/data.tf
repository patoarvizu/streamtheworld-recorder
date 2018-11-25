data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    principals {
      type = "Service"
      identifiers = [ "eks.amazonaws.com" ]
    }
    actions = [ "sts:AssumeRole" ]
  }
}

data "aws_iam_policy_document" "worker_assume_role_policy" {
  statement {
    principals {
      type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
    actions = [ "sts:AssumeRole" ]
  }
}

data "aws_ami" "eks_worker" {
  filter {
    name = "name"
    values = [ "amazon-eks-node-v*" ]
  }

  most_recent = true
  owners = [ "602401143452" ]
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

data "aws_iam_policy_document" "worker_ecr_policy" {
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
    resources = [ "*" ]
  }
}