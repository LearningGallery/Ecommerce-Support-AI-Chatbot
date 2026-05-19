locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

#------------------------------------------------------------------------------
# Origin Access Control for S3
#------------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "static" {
  name                              = "${local.name_prefix}-oac"
  description                       = "OAC for static bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#------------------------------------------------------------------------------
# CloudFront Distribution
#------------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.name_prefix} distribution"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  # Frontend origin (ALB)
  origin {
    domain_name = var.frontend_alb_dns
    origin_id   = "frontend-alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      origin_read_timeout    = 60
      origin_keepalive_timeout = 5
    }

    custom_header {
      name  = "X-Custom-Header"
      value = "${local.name_prefix}-frontend"
    }
  }

  # Backend API origin (ALB)
  origin {
    domain_name = var.backend_alb_dns
    origin_id   = "backend-alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      origin_read_timeout    = 60
      origin_keepalive_timeout = 5
    }

    custom_header {
      name  = "X-Custom-Header"
      value = "${local.name_prefix}-backend"
    }
  }

  # Static assets origin (S3)
  origin {
    domain_name              = "${var.static_bucket_name}.s3.${data.aws_region.current.name}.amazonaws.com"
    origin_id                = "static-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.static.id
  }

  # Default behavior - frontend
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "frontend-alb"

    forwarded_values {
      query_string = true
      headers      = ["Host", "CloudFront-Viewer-Country"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 3600
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.security_headers.arn
    }
  }

  # API behavior
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "backend-alb"

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Host", "Origin", "Accept", "Content-Type"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  # Static assets behavior
  ordered_cache_behavior {
    path_pattern     = "/static/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "static-s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  web_acl_id = var.enable_waf ? aws_wafv2_web_acl.main[0].arn : null

  tags = {
    Name = "${local.name_prefix}-distribution"
  }
}

#------------------------------------------------------------------------------
# CloudFront Function for Security Headers
#------------------------------------------------------------------------------
resource "aws_cloudfront_function" "security_headers" {
  name    = "${local.name_prefix}-security-headers"
  runtime = "cloudfront-js-1.0"
  comment = "Add security headers to responses"
  publish = true

  code = <<-EOT
function handler(event) {
    var response = event.response;
    var headers = response.headers;

    // Add security headers
    headers['strict-transport-security'] = { value: 'max-age=31536000; includeSubdomains; preload'};
    headers['x-content-type-options'] = { value: 'nosniff'};
    headers['x-frame-options'] = { value: 'DENY'};
    headers['x-xss-protection'] = { value: '1; mode=block'};
    headers['referrer-policy'] = { value: 'strict-origin-when-cross-origin'};

    return response;
}
EOT
}

#------------------------------------------------------------------------------
# S3 Bucket Policy for CloudFront
#------------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "static" {
  bucket = var.static_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${var.static_bucket_name}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}

#------------------------------------------------------------------------------
# WAF Web ACL (optional)
#------------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "main" {
  count = var.enable_waf ? 1 : 0

  name  = "${local.name_prefix}-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

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
      metric_name                = "${local.name_prefix}-common-rules"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.name_prefix}-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "${local.name_prefix}-waf"
  }
}

data "aws_region" "current" {}