output "address" {
  value = "${aws_instance.docker.public_ip}"
}

output "address" {
  value = "${aws_instance.db_postgres.private_ip}"
}
