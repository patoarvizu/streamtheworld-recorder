resource "aws_security_group" "stwr" {
  name = "stwr"
  vpc_id = "${data.aws_vpc.default.id}"
}

resource "aws_security_group_rule" "all_outbound" {
  type = "egress"
  cidr_blocks = [ "0.0.0.0/0" ]
  from_port = -1
  to_port = -1
  protocol = "-1"
  security_group_id = "${aws_security_group.stwr.id}"
}