#!/bin/bash

set -e

AWS_REGION="${AWS_REGION:-ap-southeast-1}"
ENVIRONMENT="${ENVIRONMENT:-dev}"

echo "=========================================="
echo "Deploying E-Commerce Chatbot"
echo "=========================================="
echo "Environment: $ENVIRONMENT"
echo "Region: $AWS_REGION"
echo "=========================================="

echo ""
echo "Step 1: Deploying infrastructure with Terraform..."
cd terraform

if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

echo "Planning infrastructure changes..."
terraform plan -out=tfplan

echo "Applying infrastructure changes..."
terraform apply tfplan

cd ..

echo ""
echo "Step 2: Building and pushing Docker images..."
./scripts/build-and-push.sh

echo ""
echo "Step 3: Updating ECS services..."
CLUSTER_NAME=$(cd terraform && terraform output -raw ecs_cluster_name)
BACKEND_SERVICE=$(cd terraform && terraform output -raw backend_service_name)
FRONTEND_SERVICE=$(cd terraform && terraform output -raw frontend_service_name)

aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $BACKEND_SERVICE \
    --force-new-deployment \
    --region $AWS_REGION

aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $FRONTEND_SERVICE \
    --force-new-deployment \
    --region $AWS_REGION

echo ""
echo "Step 4: Waiting for services to stabilize..."
aws ecs wait services-stable \
    --cluster $CLUSTER_NAME \
    --services $BACKEND_SERVICE $FRONTEND_SERVICE \
    --region $AWS_REGION

echo ""
echo "Step 5: Initializing OpenSearch..."
./scripts/init-opensearch.sh

echo ""
echo "Step 6: Loading sample FAQ data..."
./scripts/load-sample-data.sh

echo ""
echo "=========================================="
echo "Deployment completed successfully!"
echo "=========================================="
APP_URL=$(cd terraform && terraform output -raw application_url)
echo "Application URL: $APP_URL"
echo "=========================================="