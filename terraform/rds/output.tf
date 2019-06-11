output "MYSQL_HOST" {
  value = "${aws_db_instance.hardware.endpoint}"
}

output "MYSQL_USER" {
  value = "${aws_db_instance.hardware.username}"
}

output "MYSQL_DATABASE" {
  value = "${aws_db_instance.hardware.name}"
}

output "MYSQL_PASSWORD" {
  value = "Not displayed"
}
