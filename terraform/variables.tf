variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "eu-west-2"
}

variable "ami_id" {
  type        = string
  description = "Debian AMI ID"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_pair_name" {
  type        = string
  description = "Existing EC2 key pair name"
}

variable "ssh_security_group_name" {
  type        = string
  description = "Existing SSH security group name"
}

variable "cdn_security_group_name" {
  type        = string
  description = "Existing cdn security group name"
}

variable "certificate_domain" {
  description = "Domain name of the ACM certificate to attach to CloudFront"
  type        = string
}

variable "origin_secret" {
  description = "Header set by cloudfront to confirm origin"
  type        = string
}