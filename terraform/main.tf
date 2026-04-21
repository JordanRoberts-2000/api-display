terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_key_pair" "main" {
  key_name = var.key_pair_name
}

data "aws_security_group" "ssh_access" {
  name = var.ssh_security_group_name
}

data "aws_security_group" "web_access" {
  name = var.web_security_group_name
}

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.main.key_name

  vpc_security_group_ids = [
    data.aws_security_group.ssh_access.id,
    data.aws_security_group.web_access.id,
  ]

  user_data = templatefile("${path.module}/initialise.sh.tftpl", {
    image_name     = var.image_name
    host_port      = var.host_port
    container_port = var.container_port
    database_url   = var.database_url
  })

  tags = {
    Name = "api-display"
  }
}