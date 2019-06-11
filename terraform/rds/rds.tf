#Use EKS VPC and private subnets to put RDS in same private subnets

data "aws_subnet_ids" "private" {
  vpc_id = "${var.vpc_id}"

  tags = {
    tier = "private"
  }
}

data "aws_security_group" "eks-sg" {
  vpc_id = "${var.vpc_id}"
  tags = {
    Name = "terraform-eks-node"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["${data.aws_subnet_ids.private.ids}"]
  tags = {
    Name = "Hardware Subnet Group"
  }
}

resource "aws_db_instance" "hardware" {
  identifier           = "hardware-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.22"
  instance_class       = "db.t2.micro"
  name                 = "${var.rds_db}"
  username             = "${var.rds_user}"
  password             = "${var.rds_pass}"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "main"
  vpc_security_group_ids = ["${data.aws_security_group.eks-sg.id}"]
  skip_final_snapshot  = "true"
}
