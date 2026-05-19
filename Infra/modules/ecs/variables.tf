variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "task_cpu" {
  description = "Task CPU units"
  type        = number
}

variable "task_memory" {
  description = "Task memory (MB)"
  type        = number
}

variable "backend_desired_count" {
  description = "Backend desired count"
  type        = number
}

variable "frontend_desired_count" {
  description = "Frontend desired count"
  type        = number
}

variable "enable_container_insights" {
  description = "Enable Container Insights"
  type        = bool
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
}

variable "bedrock_model_id" {
  description = "Bedrock model ID"
  type        = string
}

variable "opensearch_endpoint" {
  description = "OpenSearch endpoint"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "s3_documents_bucket" {
  description = "S3 documents bucket"
  type        = string
}

variable "secrets_arn" {
  description = "Secrets Manager ARN"
  type        = string
}

variable "allowed_cors_origins" {
  description = "Allowed CORS origins"
  type        = list(string)
}