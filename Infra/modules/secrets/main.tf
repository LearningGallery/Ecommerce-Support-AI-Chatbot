locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_secretsmanager_secret" "opensearch" {
  name                    = "${local.name_prefix}-opensearch-${var.random_suffix}"
  description             = "OpenSearch credentials for chatbot"
  recovery_window_in_days = 7

  tags = {
    Name = "${local.name_prefix}-opensearch-secret"
  }
}

resource "aws_secretsmanager_secret_version" "opensearch" {
  secret_id = aws_secretsmanager_secret.opensearch.id
  secret_string = jsonencode({
    opensearch_endpoint = var.opensearch_endpoint
    opensearch_username = var.opensearch_username
    opensearch_password = var.opensearch_password
  })
}