variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "backend_cluster_name" {
  description = "Backend ECS cluster name"
  type        = string
}

variable "backend_service_name" {
  description = "Backend service name"
  type        = string
}

variable "frontend_service_name" {
  description = "Frontend service name"
  type        = string
}

variable "opensearch_domain_name" {
  description = "OpenSearch domain name"
  type        = string
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
}