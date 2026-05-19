#------------------------------------------------------------------------------
# Network Outputs
#------------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

#------------------------------------------------------------------------------
# OpenSearch Outputs
#------------------------------------------------------------------------------
output "opensearch_endpoint" {
  description = "OpenSearch domain endpoint"
  value       = module.opensearch.endpoint
  sensitive   = true
}

output "opensearch_dashboard_url" {
  description = "OpenSearch Dashboards URL"
  value       = "https://${module.opensearch.endpoint}/_dashboards"
}

output "opensearch_domain_name" {
  description = "OpenSearch domain name"
  value       = module.opensearch.domain_name
}

#------------------------------------------------------------------------------
# DynamoDB Outputs
#------------------------------------------------------------------------------
output "dynamodb_sessions_table" {
  description = "DynamoDB sessions table name"
  value       = module.dynamodb.sessions_table_name
}

output "dynamodb_messages_table" {
  description = "DynamoDB messages table name"
  value       = module.dynamodb.messages_table_name
}

#------------------------------------------------------------------------------
# S3 Outputs
#------------------------------------------------------------------------------
output "s3_documents_bucket" {
  description = "S3 bucket for documents"
  value       = module.s3.documents_bucket_name
}

output "s3_static_bucket" {
  description = "S3 bucket for static assets"
  value       = module.s3.static_bucket_name
}

#------------------------------------------------------------------------------
# ECS Outputs
#------------------------------------------------------------------------------
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "backend_service_name" {
  description = "Backend service name"
  value       = module.ecs.backend_service_name
}

output "frontend_service_name" {
  description = "Frontend service name"
  value       = module.ecs.frontend_service_name
}

output "backend_alb_dns" {
  description = "Backend ALB DNS name"
  value       = module.ecs.backend_alb_dns_name
}

output "frontend_alb_dns" {
  description = "Frontend ALB DNS name"
  value       = module.ecs.frontend_alb_dns_name
}

output "backend_ecr_repository" {
  description = "Backend ECR repository URL"
  value       = module.ecs.backend_ecr_repository_url
}

output "frontend_ecr_repository" {
  description = "Frontend ECR repository URL"
  value       = module.ecs.frontend_ecr_repository_url
}

#------------------------------------------------------------------------------
# CloudFront Outputs
#------------------------------------------------------------------------------
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = module.cloudfront.domain_name
}

output "application_url" {
  description = "Application URL (CloudFront)"
  value       = "https://${module.cloudfront.domain_name}"
}

#------------------------------------------------------------------------------
# Secrets Outputs
#------------------------------------------------------------------------------
output "secrets_manager_secret_name" {
  description = "Secrets Manager secret name"
  value       = module.secrets.secret_name
}

output "secrets_manager_secret_arn" {
  description = "Secrets Manager secret ARN"
  value       = module.secrets.secret_arn
  sensitive   = true
}

#------------------------------------------------------------------------------
# Monitoring Outputs
#------------------------------------------------------------------------------
output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.monitoring.dashboard_name
}

output "cloudwatch_log_group_backend" {
  description = "Backend CloudWatch log group"
  value       = module.ecs.backend_log_group_name
}

output "cloudwatch_log_group_frontend" {
  description = "Frontend CloudWatch log group"
  value       = module.ecs.frontend_log_group_name
}

#------------------------------------------------------------------------------
# General Outputs
#------------------------------------------------------------------------------
output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "deployment_summary" {
  description = "Deployment summary with key URLs and commands"
  value = <<-EOT
    
    ╔════════════════════════════════════════════════════════════════════╗
    ║              Deployment Complete - Summary                         ║
    ╚════════════════════════════════════════════════════════════════════╝
    
    📱 Application URL:
       https://${module.cloudfront.domain_name}
    
    🔧 Backend API:
       http://${module.ecs.backend_alb_dns_name}/api/v1/health
    
    🗄️  OpenSearch Dashboard:
       https://${module.opensearch.endpoint}/_dashboards
       (Username: admin, see Secrets Manager for password)
    
    📊 CloudWatch Dashboard:
       https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${module.monitoring.dashboard_name}
    
    🔐 Secrets Manager:
       aws secretsmanager get-secret-value --secret-id ${module.secrets.secret_name}
    
    📝 Next Steps:
       1. Build and push Docker images: ./scripts/build-and-push.sh
       2. Load sample data: ./scripts/load-sample-data.sh
       3. Run health check: ./scripts/health-check.sh
       4. View logs: aws logs tail ${module.ecs.backend_log_group_name} --follow
    
    💰 Estimated Monthly Cost: ~$260 (with current configuration)
    
    ⚠️  Important: This is a demo configuration. Review SECURITY.md
        and PRODUCTION-CHECKLIST.md before production deployment.
    
  EOT
}