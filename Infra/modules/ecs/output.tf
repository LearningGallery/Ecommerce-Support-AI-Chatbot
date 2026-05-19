output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "backend_service_name" {
  description = "Backend service name"
  value       = aws_ecs_service.backend.name
}

output "frontend_service_name" {
  description = "Frontend service name"
  value       = aws_ecs_service.frontend.name
}

output "backend_alb_dns_name" {
  description = "Backend ALB DNS name"
  value       = aws_lb.backend.dns_name
}

output "frontend_alb_dns_name" {
  description = "Frontend ALB DNS name"
  value       = aws_lb.frontend.dns_name
}

output "backend_alb_arn" {
  description = "Backend ALB ARN"
  value       = aws_lb.backend.arn
}

output "frontend_alb_arn" {
  description = "Frontend ALB ARN"
  value       = aws_lb.frontend.arn
}

output "backend_ecr_repository_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_log_group_name" {
  description = "Backend log group name"
  value       = aws_cloudwatch_log_group.backend.name
}

output "frontend_log_group_name" {
  description = "Frontend log group name"
  value       = aws_cloudwatch_log_group.frontend.name
}

output "backend_task_execution_role_arn" {
  description = "Backend task execution role ARN"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "backend_task_role_arn" {
  description = "Backend task role ARN"
  value       = aws_iam_role.backend_task.arn
}

output "backend_security_group_id" {
  description = "Backend service security group ID"
  value       = aws_security_group.backend_service.id
}

output "frontend_security_group_id" {
  description = "Frontend service security group ID"
  value       = aws_security_group.frontend_service.id
}