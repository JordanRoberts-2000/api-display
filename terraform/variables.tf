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
  default     = "ssh-access"
}

variable "web_security_group_name" {
  type        = string
  description = "Existing web security group name"
  default     = "web-access"
}

variable "image_name" {
  type        = string
  description = "Docker image to pull on boot"
}

variable "host_port" {
  type        = number
  description = "Port exposed on the EC2 instance"
  default     = 80
}

variable "container_port" {
  type        = number
  description = "Port the app listens on inside the container"
  default     = 8080
}

variable "database_url" {
  type        = string
  description = "Database URL for the container"
  sensitive   = true
}