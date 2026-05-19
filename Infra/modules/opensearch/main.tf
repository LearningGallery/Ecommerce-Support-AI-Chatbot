locals {
  name_prefix = "${var.project_name}-${var.environment}"
  domain_name = replace("${local.name_prefix}-os", "_", "-")
}

#------------------------------------------------------------------------------
# Security Group for OpenSearch
#------------------------------------------------------------------------------
resource "aws_security_group" "opensearch" {
  name_prefix = "${local.name_prefix}-opensearch-"
  description = "Security group for OpenSearch domain"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-opensearch-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Master Password
#------------------------------------------------------------------------------
resource "random_password" "opensearch_master" {
  length  = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#------------------------------------------------------------------------------
# OpenSearch Domain
#------------------------------------------------------------------------------
resource "aws_opensearch_domain" "main" {
  domain_name    = local.domain_name
  engine_version = "OpenSearch_2.11"

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = false
    zone_awareness_enabled   = var.instance_count > 1

    dynamic "zone_awareness_config" {
      for_each = var.instance_count > 1 ? [1] : []
      content {
        availability_zone_count = 2
      }
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
    volume_type = "gp3"
    iops        = 3000
    throughput  = 125
  }

  vpc_options {
    subnet_ids         = var.instance_count > 1 ? slice(var.subnet_ids, 0, 2) : [var.subnet_ids[0]]
    security_group_ids = [aws_security_group.opensearch.id]
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "admin"
      master_user_password = random_password.opensearch_master.result
    }
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "es:*"
        Resource = "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${local.domain_name}/*"
      }
    ]
  })

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  tags = {
    Name = "${local.name_prefix}-opensearch"
  }
}

#------------------------------------------------------------------------------
# CloudWatch Log Group for OpenSearch
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "opensearch" {
  name              = "/aws/opensearch/${local.domain_name}"
  retention_in_days = 7

  tags = {
    Name = "${local.name_prefix}-opensearch-logs"
  }
}

#------------------------------------------------------------------------------
# CloudWatch Log Resource Policy
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_resource_policy" "opensearch" {
  policy_name = "${local.name_prefix}-opensearch-logs-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream"
        ]
        Resource = "${aws_cloudwatch_log_group.opensearch.arn}:*"
      }
    ]
  })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}