locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#------------------------------------------------------------------------------
# Networking Module
#------------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
}

#------------------------------------------------------------------------------
# S3 Module
#------------------------------------------------------------------------------
module "s3" {
  source = "./modules/s3"

  project_name  = var.project_name
  environment   = var.environment
  random_suffix = random_string.suffix.result
}

#------------------------------------------------------------------------------
# DynamoDB Module
#------------------------------------------------------------------------------
module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
}

#------------------------------------------------------------------------------
# OpenSearch Module
#------------------------------------------------------------------------------
module "opensearch" {
  source = "./modules/opensearch"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  subnet_ids          = module.networking.private_subnet_ids
  instance_type       = var.opensearch_instance_type
  instance_count      = var.opensearch_instance_count
  ebs_volume_size     = var.opensearch_ebs_volume_size
  allowed_cidr_blocks = [var.vpc_cidr]
}

#------------------------------------------------------------------------------
# Secrets Manager Module
#------------------------------------------------------------------------------
module "secrets" {
  source = "./modules/secrets"

  project_name  = var.project_name
  environment   = var.environment
  random_suffix = random_string.suffix.result

  opensearch_endpoint = module.opensearch.endpoint
  opensearch_username = module.opensearch.master_username
  opensearch_password = module.opensearch.master_password
}

#------------------------------------------------------------------------------
# ECS Cluster and Services Module
#------------------------------------------------------------------------------
module "ecs" {
  source = "./modules/ecs"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.networking.vpc_id
  private_subnet_ids        = module.networking.private_subnet_ids
  public_subnet_ids         = module.networking.public_subnet_ids
  
  task_cpu                  = var.ecs_task_cpu
  task_memory               = var.ecs_task_memory
  backend_desired_count     = var.backend_desired_count
  frontend_desired_count    = var.frontend_desired_count
  
  enable_container_insights = var.enable_container_insights
  log_retention_days        = var.log_retention_days
  
  # Environment variables
  bedrock_model_id          = var.bedrock_model_id
  opensearch_endpoint       = module.opensearch.endpoint
  dynamodb_table_name       = module.dynamodb.sessions_table_name
  s3_documents_bucket       = module.s3.documents_bucket_name
  secrets_arn               = module.secrets.secret_arn
  
  allowed_cors_origins      = var.allowed_cors_origins
}

#------------------------------------------------------------------------------
# CloudFront Module
#------------------------------------------------------------------------------
module "cloudfront" {
  source = "./modules/cloudfront"

  project_name       = var.project_name
  environment        = var.environment
  frontend_alb_dns   = module.ecs.frontend_alb_dns_name
  backend_alb_dns    = module.ecs.backend_alb_dns_name
  static_bucket_name = module.s3.static_bucket_name
  enable_waf         = var.enable_waf
}

#------------------------------------------------------------------------------
# Monitoring Module
#------------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  project_name           = var.project_name
  environment            = var.environment
  backend_cluster_name   = module.ecs.cluster_name
  backend_service_name   = module.ecs.backend_service_name
  frontend_service_name  = module.ecs.frontend_service_name
  opensearch_domain_name = module.opensearch.domain_name
  log_retention_days     = var.log_retention_days
}