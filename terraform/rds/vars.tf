variable "project_name"  {
  default = "gill-hicks"
}

variable "vpc_id" {
  description = "Enter EKS VPC ID"
}

variable "rds_pass" {
  description = "Enter MYSQL_PASSWORD, 8 characters or more"
}

variable "rds_user" {
  description = "Enter MYSQL_USER"
}

variable "rds_db" {
  description = "Enter MYSQL_DATABASE"
}
