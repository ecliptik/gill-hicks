variable "project_name"  {
  default = "gill-hicks"
}

variable "cluster-name" {
  default = "eks-gill-hicks"
  type    = "string"
}

variable "zones" {
  default = {
    zone0 = "us-east-1a"
    zone1 = "us-east-1b"
  }
}

variable "cidr_block" {
  default = "10.1"
}

variable "cidr_blocks_public" {
  default = {
    zone0 = "10.1.1.0/22"
    zone1 = "10.1.10.0/22"
  }
}


variable "cidr_blocks_private" {
  default = {
    zone0 = "10.1.20.0/22"
    zone1 = "10.1.30.0/22"
  }
}
