resource "aws_security_group" "master" {
  name = "${local.cluster_name}-master"
  vpc_id = "${aws_vpc.stwr.id}"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_security_group_rule" "home" {
  cidr_blocks = [ "173.56.236.148/32" ]
  from_port = 443
  protocol = "tcp"
  security_group_id = "${aws_security_group.master.id}"
  to_port = 443
  type = "ingress"
}

resource "aws_security_group_rule" "asapp_vpn" {
  cidr_blocks = [ "144.121.114.178/32" ]
  from_port = 443
  protocol = "tcp"
  security_group_id = "${aws_security_group.master.id}"
  to_port = 443
  type = "ingress"
}

resource "aws_security_group" "worker" {
  name = "${local.cluster_name}-worker"
  vpc_id = "${aws_vpc.stwr.id}"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = "${
    map(
      "Name", "${local.cluster_name}-node",
      "kubernetes.io/cluster/${local.cluster_name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "worker_ingress_self" {
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.worker.id}"
  to_port = 65535
  type = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_master" {
  from_port = 1025
  protocol = "tcp"
  security_group_id = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.master.id}"
  to_port = 65535
  type = "ingress"
}

resource "aws_security_group_rule" "workers_to_masters_https" {
  from_port = 443
  protocol = "tcp"
  security_group_id = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.worker.id}"
  to_port = 443
  type = "ingress"
}

resource "aws_launch_configuration" "stwr" {
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.worker.name}"
  image_id = "${data.aws_ami.eks_worker.id}"
  instance_type = "t3.micro"
  name_prefix = "${local.cluster_name}-"
  security_groups = [ "${aws_security_group.worker.id}" ]
  user_data_base64 = "${base64encode(local.worker_user_data)}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "stwr" {
  launch_configuration = "${aws_launch_configuration.stwr.id}"
  max_size = 1
  min_size = 0
  name = "${local.cluster_name}-workers"
  vpc_zone_identifier = [ "${aws_subnet.stwr.*.id}" ]
  tag {
    key = "Name"
    value = "${local.cluster_name}-node"
    propagate_at_launch = true
  }
  tag {
    key = "kubernetes.io/cluster/${local.cluster_name}"
    value = "owned"
    propagate_at_launch = true
  }
}