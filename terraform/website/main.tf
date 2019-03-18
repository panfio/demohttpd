provider "aws" {
  region     = "${var.aws_region}"
}

resource "aws_instance" "docker" {
  #ami = "${lookup(var.aws_amis, var.aws_region)}"
  ami                         = "ami-011b3ccf1bd6db744"
  instance_type               = "t2.micro"
  key_name                    = "jenkins_server"
  vpc_security_group_ids      = ["sg-013303dd98e21f134"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/../data/aws_launch_configuration_docker")}"

  tags = {
    Name = "docker"
  }

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }
}

resource "aws_instance" "db_postgres" {
  #ami = "${lookup(var.aws_amis, var.aws_region)}"
  ami                         = "ami-011b3ccf1bd6db744"
  instance_type               = "t2.micro"
  key_name                    = "jenkins_server"
  vpc_security_group_ids      = ["sg-013303dd98e21f134"]
  user_data                   = "${file("${path.module}/../data/aws_launch_configuration_db_postgres")}"

  tags = {
    Name = "postgres_server"
  }

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }
}
