output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "backend_cpu_alarm_arn" {
  description = "Backend CPU alarm ARN"
  value       = aws_cloudwatch_metric_alarm.backend_cpu_high.arn
}

output "backend_memory_alarm_arn" {
  description = "Backend memory alarm ARN"
  value       = aws_cloudwatch_metric_alarm.backend_memory_high.arn
}

output "opensearch_alarm_arn" {
  description = "OpenSearch cluster alarm ARN"
  value       = aws_cloudwatch_metric_alarm.opensearch_cluster_red.arn
}