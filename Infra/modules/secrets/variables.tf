variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "random_suffix" {
  description = "Random suffix for unique naming"
  type        = string
}

variable "opensearch_endpoint" {
  description = "OpenSearch endpoint"
  type        = string
}

variable "opensearch_username" {
  description = "OpenSearch username"
  type        = string
  sensitive   = true
}

variable "opensearch_password" {
  description = "OpenSearch password"
  type        = string
  sensitive   = true
}