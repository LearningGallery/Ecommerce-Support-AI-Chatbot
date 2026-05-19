variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "frontend_alb_dns" {
  description = "Frontend ALB DNS name"
  type        = string
}

variable "backend_alb_dns" {
  description = "Backend ALB DNS name"
  type        = string
}

variable "static_bucket_name" {
  description = "Static assets bucket name"
  type        = string
}

variable "enable_waf" {
  description = "Enable AWS WAF"
  type        = bool
  default     = false
}