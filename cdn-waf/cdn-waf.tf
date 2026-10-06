# CloudFront distribution + WAFv2 web ACL for the Orders origin. NEVER applied here: validate-only.
# Cost note: WAF ~USD 5/month per web ACL + 1/rule + per-request fees; CloudFront has a free tier.
terraform {
  required_version = "~> 1.9"
  required_providers {
    aws = { source = "hashicorp/aws", version = "5.81.0" }
  }
}

provider "aws" {
  region                      = "us-east-1" # CLOUDFRONT-scope WAF must live here
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "validate-only"
  secret_key                  = "validate-only"
}

resource "aws_wafv2_web_acl" "orders" {
  name  = "orders-acl"
  scope = "CLOUDFRONT"
  default_action {
    allow {}
  }
  rule {
    name     = "aws-common"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "rate-limit"
    priority = 2
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "orders-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudfront_distribution" "orders" {
  enabled          = true
  http_version     = "http2and3"
  web_acl_id       = aws_wafv2_web_acl.orders.arn
  price_class      = "PriceClass_100"
  retain_on_delete = false

  origin {
    domain_name = "origin.example.com"
    origin_id   = "orders-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "orders-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
