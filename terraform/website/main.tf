provider "aws" {
  region     = "${var.aws_region}"
}

resource "aws_instance" "docker" {
  #ami = "${lookup(var.aws_amis, var.aws_region)}"
  ami                         = "ami-011b3ccf1bd6db744"
  instance_type               = "t2.micro"
  key_name                    = "jenkins_server"
  vpc_security_group_ids      = ["${aws_security_group.jenkins_server.id}"]
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
  vpc_security_group_ids      = ["${aws_security_group.jenkins_server.id}"]
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

resource "aws_security_group" "jenkins_server" {
  name        = "jenkins_server"
  description = "Open required ports to server"

  tags = {
    Name                  = "jenkins_server"
  }
}

resource "aws_security_group_rule" "https-jenkins_server" {
  type              = "ingress"
  security_group_id        = "${aws_security_group.jenkins_server.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http-jenkins_server" {
  type              = "ingress"
  security_group_id        = "${aws_security_group.jenkins_server.id}"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http8080-jenkins_server" {
  type              = "ingress"
  security_group_id        = "${aws_security_group.jenkins_server.id}"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_server-ssh" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.jenkins_server.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "jenkins_server-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.jenkins_server.id}"
  from_port                = 1000
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "jenkins_server-egress" {
  type              = "egress"
  security_group_id        = "${aws_security_group.jenkins_server.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
