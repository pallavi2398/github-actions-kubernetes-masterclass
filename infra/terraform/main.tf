terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.env}-terra-automate-key"
  public_key = file(var.public_key_path)
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "app_server" {
  name        = "${var.env}-skillpulse-app-server-sg"
  description = "Security group for the SkillPulse deployment server"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.app_server.id
  cidr_ipv4         = var.allowed_ssh_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.app_server.id
  cidr_ipv4         = var.allowed_http_cidr
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.app_server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "app_server" {
  count = var.ec2_instance_count

  ami                         = var.ec2_ami_id
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids      = [aws_security_group.app_server.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = "gp3"
  }

  tags = {
    Name        = "${var.env}-${var.ec2_instance_name}-${count.index + 1}"
    Environment = var.env
    Project     = "skillpulse"
  }
}
