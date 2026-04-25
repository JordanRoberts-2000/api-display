terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
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

// creating the role and defining who can use it
resource "aws_iam_role" "app" {
  name = "api-display-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

// attaching policies
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

// the glue between EC2 and IAM
resource "aws_iam_instance_profile" "app" {
  name = "api-display-ec2-profile"
  role = aws_iam_role.app.name
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/api-display"
  retention_in_days = 30
}

resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.main.key_name
  iam_instance_profile = aws_iam_instance_profile.app.name

  vpc_security_group_ids = [
    data.aws_security_group.ssh_access.id,
    data.aws_security_group.web_access.id,
  ]

  tags = {
    Name = "api-display"
  }
}

output "public_ip" {
  value = aws_instance.app.public_ip
}