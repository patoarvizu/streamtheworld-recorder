resource "aws_vpc" "stwr" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = "${
    map(
      "Name", "${local.cluster_name}-node",
      "kubernetes.io/cluster/${local.cluster_name}", "shared",
    )
  }"
}

resource "aws_subnet" "stwr" {
  count = 2
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block = "10.0.${count.index}.0/24"
  vpc_id = "${aws_vpc.stwr.id}"
  tags = "${
    map(
      "Name", "${local.cluster_name}-node",
      "kubernetes.io/cluster/${local.cluster_name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.stwr.id}"
  tags = "${
    map(
      "Name", "${local.cluster_name}"
    )
  }"
}

resource "aws_route_table" "rtb" {
  vpc_id = "${aws_vpc.stwr.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  } 
}

resource "aws_route_table_association" "rtba" {
  count = 2
  subnet_id = "${aws_subnet.stwr.*.id[count.index]}"
  route_table_id = "${aws_route_table.rtb.id}"
}
