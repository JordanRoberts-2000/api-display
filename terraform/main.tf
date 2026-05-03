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
  region = var.aws_region  # ← default/connection 1
}

provider "aws" {
  alias  = "us_east_1"     # ← connection 2, only used when explicitly referenced
  region = "us-east-1"
}

data "aws_key_pair" "main" {
  key_name = var.key_pair_name
}

data "aws_security_group" "ssh_access" {
  name = var.ssh_security_group_name
}

data "aws_security_group" "cloudfront_access" {
  name = var.cdn_security_group_name
}

data "aws_acm_certificate" "main" {
  provider    = aws.us_east_1
  domain      = var.certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

// cloudfront policies
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host_header" {
  name = "Managed-AllViewerExceptHostHeader"
}

// route 53
data "aws_route53_zone" "main" {
  name = "strawr.dev"
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
    data.aws_security_group.cloudfront_access.id,
  ]

  tags = {
    Name = "api-display"
  }
}

# Cloudfront cdn
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  comment             = "api-display CDN"
  default_root_object = ""
  aliases             = ["api-display.strawr.dev"]

  # Origin — EC2 over plain HTTP on port 80
  origin {
    domain_name = aws_instance.app.public_dns
    origin_id   = "ec2-origin"

    custom_header {
    name  = "X-Origin-Secret"
    value = var.origin_secret  # a long random string, e.g. a UUID
  }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

    # ── /assets/* ── CachingOptimized | AllViewer | GET+HEAD only ────────────
  ordered_cache_behavior {
    path_pattern             = "/assets/*"
    target_origin_id         = "ec2-origin"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimized.id
     origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
  }

  # ── /api/* ── CachingDisabled | no origin request policy | all methods ───
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "ec2-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = false
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_disabled.id
     origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
  }

  # ── * default ── CachingDisabled | AllViewerExceptHostHeader ─────────────
  default_cache_behavior {
    target_origin_id         = "ec2-origin"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = false
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id
  }

  # HTTPS with your existing ACM cert
  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.main.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "api-display"
  }
}

resource "aws_route53_record" "cloudfront" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api-display.strawr.dev"
  type    = "CNAME"
  ttl     = 300
  records = [aws_cloudfront_distribution.main.domain_name]
}

output "public_ip" {
  value = aws_instance.app.public_ip
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}