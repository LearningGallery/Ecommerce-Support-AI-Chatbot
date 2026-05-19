# Deployment Guide

## 1. Overview

This guide explains how to deploy the E-Commerce Customer Support AI Chatbot on AWS using Terraform, Docker, ECS Fargate, Amazon Bedrock, OpenSearch, and DynamoDB.

---

## 2. Prerequisites

### Required Tools
- AWS CLI v2
- Terraform >= 1.6.0
- Docker
- Python 3.11+
- Node.js 20+
- jq
- Git

### AWS Requirements
- AWS account with permissions for:
  - VPC
  - ECS
  - ECR
  - IAM
  - OpenSearch
  - DynamoDB
  - S3
  - CloudFront
  - CloudWatch
  - Secrets Manager
  - Bedrock
- Bedrock model access enabled

### Recommended Region
- `ap-southeast-1`

---

## 3. Clone Repository

```bash
git clone https://github.com/your-username/ecommerce-support-chatbot.git
cd ecommerce-support-chatbot
```

---

## 4. Configure AWS CLI

```bash
aws configure
```

Verify:
```bash
aws sts get-caller-identity
```

---

## 5. Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
project_name = "ecommerce-chatbot"
environment  = "dev"
owner_email  = "your-email@example.com"
aws_region   = "ap-southeast-1"
```

---

## 6. Initialize Terraform

```bash
terraform init
```

---

## 7. Plan Infrastructure

```bash
terraform plan -out=tfplan
```

Review outputs carefully.

---

## 8. Apply Infrastructure

```bash
terraform apply tfplan
```

This may take 15–30 minutes depending on OpenSearch provisioning.

---

## 9. Build and Push Images

From repository root:

```bash
chmod +x scripts/*.sh
./scripts/build-and-push.sh
```

This script:
- logs in to ECR
- builds backend image
- builds frontend image
- pushes images to ECR

---

## 10. Deploy Application Services

```bash
./scripts/deploy.sh
```

This script:
- applies Terraform if needed
- builds and pushes images
- updates ECS services
- waits for service stabilization
- initializes OpenSearch
- loads sample FAQ data

---

## 11. Initialize OpenSearch Manually (Optional)

```bash
./scripts/init-opensearch.sh
```

---

## 12. Load Sample FAQ Data

```bash
./scripts/load-sample-data.sh
```

---

## 13. Validate Deployment

### Health Check
```bash
./scripts/health-check.sh
```

### Get Application URL
```bash
cd terraform
terraform output application_url
```

### Test Backend API
```bash
BACKEND_URL=$(terraform output -raw backend_alb_dns)

curl "http://$BACKEND_URL/api/v1/health"
```

### Test Chat Endpoint
```bash
curl -X POST "http://$BACKEND_URL/api/v1/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What is your shipping policy?",
    "use_rag": true
  }'
```

---

## 14. Local Development

### Backend
```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn main:app --reload --port 8000
```

### Frontend
```bash
cd frontend
npm install
cp .env.example .env
npm run dev
```

---

## 15. Environment Variables

### Backend
Required:
- `AWS_REGION`
- `BEDROCK_MODEL_ID`
- `OPENSEARCH_ENDPOINT`
- `OPENSEARCH_USERNAME`
- `OPENSEARCH_PASSWORD`
- `DYNAMODB_TABLE_NAME`
- `S3_DOCUMENTS_BUCKET`

### Frontend
Required:
- `VITE_API_ENDPOINT`

---

## 16. Rollback Procedure

### ECS Rollback
Rollback by redeploying a previous image tag:

```bash
aws ecs update-service \
  --cluster <cluster-name> \
  --service <service-name> \
  --force-new-deployment
```

If you use immutable tags, update task definition to previous image.

### Terraform Rollback
Terraform does not have a native rollback command. Use:
- version control for Terraform changes
- `terraform plan`
- re-apply previous configuration

---

## 17. Destroy Infrastructure

```bash
cd terraform
terraform destroy
```

Use with caution.

---

## 18. Common Deployment Issues

### Bedrock Access Denied
Cause:
- model access not enabled

Fix:
- enable Claude model access in Bedrock console

### OpenSearch Provisioning Delay
Cause:
- domain creation takes time

Fix:
- wait longer and re-run health checks

### ECS Tasks Failing
Cause:
- environment variables or image issues

Fix:
- inspect CloudWatch logs
- confirm ECR image exists
- verify Secrets Manager access

### Frontend Cannot Reach Backend
Cause:
- incorrect API endpoint
- ALB or CloudFront path issue

Fix:
- verify `VITE_API_ENDPOINT`
- verify backend ALB is healthy

---

## 19. Versioning Strategy

Recommended:
- `latest` for demo simplicity
- Git SHA tag for traceability

Example:
```bash
docker tag backend:latest <ecr-url>:$(git rev-parse --short HEAD)
```

Production recommendation:
- semantic version tags
- release branches
- immutable deployment promotion

---

## 20. Production Deployment Recommendations

- use remote Terraform backend
- use separate environments: dev / staging / prod
- use CI/CD pipeline
- use custom domain and ACM
- enable WAF
- enable Cognito
- restrict CORS
- use private service discovery where needed
- run load tests before go-live