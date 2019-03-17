provider "aws" {
  region     = "${var.aws_region}"
}

resource "aws_instance" "jenkins" {
  #ami = "${lookup(var.aws_amis, var.aws_region)}"
  ami                         = "ami-011b3ccf1bd6db744"
  instance_type               = "t2.micro"
  key_name                    = "jenkins_server"
  vpc_security_group_ids      = ["sg-013303dd98e21f134"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/../data/aws_launch_configuration_jenkins")}"

  tags = {
    Name = "jenkins_server"
  }

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }
}
