output "domain_name" {
  description = "OpenSearch domain name"
  value       = aws_opensearch_domain.main.domain_name
}

output "domain_id" {
  description = "OpenSearch domain ID"
  value       = aws_opensearch_domain.main.domain_id
}

output "endpoint" {
  description = "OpenSearch domain endpoint"
  value       = aws_opensearch_domain.main.endpoint
}

output "dashboard_endpoint" {
  description = "OpenSearch Dashboards endpoint"
  value       = aws_opensearch_domain.main.dashboard_endpoint
}

output "arn" {
  description = "OpenSearch domain ARN"
  value       = aws_opensearch_domain.main.arn
}

output "master_username" {
  description = "Master username"
  value       = "admin"
  sensitive   = true
}

output "master_password" {
  description = "Master password"
  value       = random_password.opensearch_master.result
  sensitive   = true
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.opensearch.id
}
