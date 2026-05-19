#!/bin/bash

set -e

AWS_REGION="${AWS_REGION:-ap-southeast-1}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ENVIRONMENT="${ENVIRONMENT:-dev}"

BACKEND_ECR=$(cd terraform && terraform output -raw backend_ecr_repository)
FRONTEND_ECR=$(cd terraform && terraform output -raw frontend_ecr_repository)

echo "=========================================="
echo "Building and Pushing Docker Images"
echo "=========================================="
echo "AWS Account: $AWS_ACCOUNT_ID"
echo "Region: $AWS_REGION"
echo "Environment: $ENVIRONMENT"
echo "=========================================="

echo "Logging into Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

echo ""
echo "Building backend image..."
cd backend
docker build -t $BACKEND_ECR:latest .
docker tag $BACKEND_ECR:latest $BACKEND_ECR:$(git rev-parse --short HEAD)

echo "Pushing backend image..."
docker push $BACKEND_ECR:latest
docker push $BACKEND_ECR:$(git rev-parse --short HEAD)
cd ..

echo ""
echo "Building frontend image..."
cd frontend
docker build -t $FRONTEND_ECR:latest .
docker tag $FRONTEND_ECR:latest $FRONTEND_ECR:$(git rev-parse --short HEAD)

echo "Pushing frontend image..."
docker push $FRONTEND_ECR:latest
docker push $FRONTEND_ECR:$(git rev-parse --short HEAD)
cd ..

echo ""
echo "=========================================="
echo "Build and push completed successfully!"
echo "Backend:  $BACKEND_ECR:latest"
echo "Frontend: $FRONTEND_ECR:latest"
echo "=========================================="