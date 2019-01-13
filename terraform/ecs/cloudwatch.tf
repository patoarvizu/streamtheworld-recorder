resource "aws_cloudwatch_log_group" "stwr" {
  name_prefix = "stwr-"
  retention_in_days = 1
}