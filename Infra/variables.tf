variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "ecommerce-chatbot"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "owner_email" {
  description = "Email of the resource owner"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "opensearch_instance_type" {
  description = "OpenSearch instance type"
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_instance_count" {
  description = "Number of OpenSearch instances"
  type        = number
  default     = 1

  validation {
    condition     = var.opensearch_instance_count >= 1 && var.opensearch_instance_count <= 10
    error_message = "OpenSearch instance count must be between 1 and 10."
  }
}

variable "opensearch_ebs_volume_size" {
  description = "EBS volume size for OpenSearch (GB)"
  type        = number
  default     = 10

  validation {
    condition     = var.opensearch_ebs_volume_size >= 10 && var.opensearch_ebs_volume_size <= 1000
    error_message = "EBS volume size must be between 10 and 1000 GB."
  }
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.ecs_task_cpu)
    error_message = "ECS task CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "ecs_task_memory" {
  description = "Memory for ECS task (MB)"
  type        = number
  default     = 1024

  validation {
    condition     = var.ecs_task_memory >= 512 && var.ecs_task_memory <= 30720
    error_message = "ECS task memory must be between 512 and 30720 MB."
  }
}

variable "backend_desired_count" {
  description = "Desired count of backend tasks"
  type        = number
  default     = 2

  validation {
    condition     = var.backend_desired_count >= 1 && var.backend_desired_count <= 10
    error_message = "Backend desired count must be between 1 and 10."
  }
}

variable "frontend_desired_count" {
  description = "Desired count of frontend tasks"
  type        = number
  default     = 2

  validation {
    condition     = var.frontend_desired_count >= 1 && var.frontend_desired_count <= 10
    error_message = "Frontend desired count must be between 1 and 10."
  }
}

variable "bedrock_model_id" {
  description = "Amazon Bedrock model ID"
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "enable_waf" {
  description = "Enable AWS WAF for CloudFront"
  type        = bool
  default     = false
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch Logs retention period."
  }
}

variable "allowed_cors_origins" {
  description = "Allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets (set to false to save costs in dev)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway instead of one per AZ (cost optimization)"
  type        = bool
  default     = false
}