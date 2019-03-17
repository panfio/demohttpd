output "address" {
  value = "${aws_instance.jenkins.public_ip}"
}
