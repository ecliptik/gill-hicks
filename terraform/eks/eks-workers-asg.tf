# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We implement a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.12-v20190329"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}


resource "aws_launch_configuration" "eks" {
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t3.small"
  name_prefix                 = "terraform-eks-node-"
  security_groups             = ["${aws_security_group.node.id}"]
  user_data_base64            = "${base64encode(local.eks-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks-node" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.eks.id}"
  max_size             = 2
  min_size             = 1
  name                 = "terraform-eks"
  vpc_zone_identifier  = ["${aws_subnet.private_subnet.*.id}"]

  tag {
    key                 = "Name"
    value               = "terraform-eks-nodes"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

