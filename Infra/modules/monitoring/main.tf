locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

#------------------------------------------------------------------------------
# CloudWatch Dashboard
#------------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", var.backend_service_name, "ClusterName", var.backend_cluster_name, { stat = "Average", label = "Backend CPU" }],
            ["...", var.frontend_service_name, ".", ".", { stat = "Average", label = "Frontend CPU" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ECS CPU Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", var.backend_service_name, "ClusterName", var.backend_cluster_name, { stat = "Average", label = "Backend Memory" }],
            ["...", var.frontend_service_name, ".", ".", { stat = "Average", label = "Frontend Memory" }]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ECS Memory Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type = "metric"
        x    = 0
        y    = 6
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average", label = "Response Time" }],
            [".", "RequestCount", { stat = "Sum", label = "Request Count", yAxis = "right" }]
          ]
          period = 300
          region = data.aws_region.current.name
          title  = "ALB Metrics"
          yAxis = {
            left = {
              label = "Response Time (seconds)"
            }
            right = {
              label = "Request Count"
            }
          }
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 6
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ES", "ClusterStatus.green", "DomainName", var.opensearch_domain_name, "ClientId", data.aws_caller_identity.current.account_id, { stat = "Average", label = "Cluster Green" }],
            [".", "SearchRate", ".", ".", ".", ".", { stat = "Sum", label = "Search Rate", yAxis = "right" }]
          ]
          period = 300
          region = data.aws_region.current.name
          title  = "OpenSearch Metrics"
        }
      },
      {
        type = "log"
        x    = 0
        y    = 12
        width = 24
        height = 6
        properties = {
          query = "SOURCE '/ecs/${local.name_prefix}/backend' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20"
          region = data.aws_region.current.name
          title = "Recent Backend Errors"
        }
      }
    ]
  })
}

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------

# Backend CPU High
resource "aws_cloudwatch_metric_alarm" "backend_cpu_high" {
  alarm_name          = "${local.name_prefix}-backend-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Backend CPU utilization is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.backend_cluster_name
    ServiceName = var.backend_service_name
  }

  tags = {
    Name = "${local.name_prefix}-backend-cpu-alarm"
  }
}

# Backend Memory High
resource "aws_cloudwatch_metric_alarm" "backend_memory_high" {
  alarm_name          = "${local.name_prefix}-backend-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Backend memory utilization is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.backend_cluster_name
    ServiceName = var.backend_service_name
  }

  tags = {
    Name = "${local.name_prefix}-backend-memory-alarm"
  }
}

# OpenSearch Cluster Red
resource "aws_cloudwatch_metric_alarm" "opensearch_cluster_red" {
  alarm_name          = "${local.name_prefix}-opensearch-cluster-red"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ClusterStatus.green"
  namespace           = "AWS/ES"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "OpenSearch cluster status is red"
  treat_missing_data  = "breaching"

  dimensions = {
    DomainName = var.opensearch_domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }

  tags = {
    Name = "${local.name_prefix}-opensearch-alarm"
  }
}

# ALB Unhealthy Targets
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name          = "${local.name_prefix}-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "ALB has unhealthy targets"
  treat_missing_data  = "notBreaching"

  tags = {
    Name = "${local.name_prefix}-alb-unhealthy-alarm"
  }
}

#------------------------------------------------------------------------------
# Log Insights Queries
#------------------------------------------------------------------------------
resource "aws_cloudwatch_query_definition" "error_logs" {
  name = "${local.name_prefix}-error-logs"

  log_group_names = [
    "/ecs/${local.name_prefix}/backend",
    "/ecs/${local.name_prefix}/frontend"
  ]

  query_string = <<-QUERY
    fields @timestamp, @message
    | filter @message like /ERROR/
    | sort @timestamp desc
    | limit 100
  QUERY
}

resource "aws_cloudwatch_query_definition" "response_times" {
  name = "${local.name_prefix}-response-times"

  log_group_names = [
    "/ecs/${local.name_prefix}/backend"
  ]

  query_string = <<-QUERY
    fields @timestamp, response_time
    | filter response_time > 0
    | stats avg(response_time) as avg_response_time, max(response_time) as max_response_time, min(response_time) as min_response_time by bin(5m)
    | sort @timestamp desc
  QUERY
}

resource "aws_cloudwatch_query_definition" "bedrock_calls" {
  name = "${local.name_prefix}-bedrock-calls"

  log_group_names = [
    "/ecs/${local.name_prefix}/backend"
  ]

  query_string = <<-QUERY
    fields @timestamp, @message
    | filter @message like /Invoking Bedrock/
    | parse @message "took * seconds" as duration
    | stats count() as call_count, avg(duration) as avg_duration by bin(5m)
    | sort @timestamp desc
  QUERY
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}