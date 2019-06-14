# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {}

resource "aws_vpc" "eks" {
  cidr_block = "${var.cidr_block}.0.0/16"
  enable_dns_hostnames = "true"
  instance_tenancy = "default"

  tags = "${
    map(
     "Name", "terraform-eks",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = "${aws_vpc.eks.id}"
  cidr_block = "${lookup(var.cidr_blocks_public, format("zone%d", count.index))}"
  availability_zone = "${lookup(var.zones, format("zone%d", count.index))}"
  map_public_ip_on_launch = "true"
  count=2

  tags = "${
    map(
     "Name", "public-${lookup(var.zones, format("zone%d", count.index))}",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
     "tier", "public",
     "kubernetes.io/role/elb", "1"

    )
  }"

}

resource "aws_subnet" "private_subnet" {
  vpc_id     = "${aws_vpc.eks.id}"
  cidr_block = "${lookup(var.cidr_blocks_private, format("zone%d", count.index))}"
  availability_zone = "${lookup(var.zones, format("zone%d", count.index))}"
  map_public_ip_on_launch = "false"
  count=2

  tags = "${
    map(
     "Name", "private-${lookup(var.zones, format("zone%d", count.index))}",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
     "tier", "private",
     "kubernetes.io/role/internal-elb", "1"
    )
  }"
}

resource "aws_internet_gateway" "eks" {
  vpc_id = "${aws_vpc.eks.id}"

  tags = {
    Name = "terraform-eks"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.eks.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks.id}"
  }

tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.eks.id}"
  count="${length(var.cidr_blocks_private)}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id     = "${element(aws_nat_gateway.eks.*.id, count.index)}"
  }

tags = {
    Name = "private-${lookup(var.zones, format("zone%d", count.index))}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${(aws_route_table.public.id)}"
  count="${length(var.cidr_blocks_public)}"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${element(aws_subnet.private_subnet.*.id , count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count="${length(var.cidr_blocks_private)}"
}

resource "aws_nat_gateway" "eks" {
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  count="${length(var.cidr_blocks_public)}"

  tags = {
    Name = "Gateway NAT"
  }
}

resource "aws_eip" "nat" {
  vpc      = true
  count="${length(var.cidr_blocks_public)}"
  tags = {
    Name = "public-${var.project_name}-${lookup(var.zones, format("zone%d", count.index))}"
  }
}

#outputs
output "vpc-id" {
  value = "${aws_vpc.eks.id}"
}

output "public-subnets" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}

output "private-subnets" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}
