resource "aws_ecr_repository" "stwr" {
  name = "streamtheworld-recorder"
}

resource "aws_ecr_repository_policy" "stwr" {
  repository = "${aws_ecr_repository.stwr.name}"
  policy = "${data.aws_iam_policy_document.ecr_repo_policy.json}"
}