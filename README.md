# 🤖 E-Commerce Customer Support AI Chatbot

![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Bedrock](https://img.shields.io/badge/Amazon-Bedrock-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![OpenSearch](https://img.shields.io/badge/OpenSearch-RAG-005EB8?style=for-the-badge&logo=opensearch&logoColor=white)
![ECS Fargate](https://img.shields.io/badge/ECS-Fargate-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![CloudFront](https://img.shields.io/badge/CloudFront-CDN-8C4FFF?style=for-the-badge&logo=amazonaws&logoColor=white)
![S3](https://img.shields.io/badge/S3-Storage-569A31?style=for-the-badge&logo=amazons3&logoColor=white)
![RAG](https://img.shields.io/badge/RAG-Enabled-blue?style=for-the-badge)
![LLM](https://img.shields.io/badge/LLM-Integrated-green?style=for-the-badge)
![Docs](https://img.shields.io/badge/Docs-Complete-informational?style=for-the-badge)
![Demo Ready](https://img.shields.io/badge/Demo-Ready-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

## Overview

A complete end-to-end **AWS-native AI chatbot** for **e-commerce customer support**, built for:
- GitHub portfolio showcase
- AI / cloud architecture demonstration
- reusable AWS reference implementation
- learning and technical documentation

The chatbot supports:
- interactive chat
- LLM-powered answers via Amazon Bedrock
- FAQ / policy retrieval using RAG
- optional order help
- source citations
- session persistence
- Terraform-based deployment

---

## Architecture Summary

### Core Services
- **Frontend**: React + TypeScript
- **Backend**: FastAPI + Python
- **LLM**: Amazon Bedrock
- **Knowledge Base**: OpenSearch
- **Session Store**: DynamoDB
- **Storage**: S3
- **Compute**: ECS Fargate
- **CDN**: CloudFront
- **Observability**: CloudWatch
- **Secrets**: Secrets Manager

### Architecture Pattern
This solution uses a **Retrieval-Augmented Generation (RAG)** pattern:
1. user asks a question
2. backend retrieves relevant FAQ/policy content
3. backend builds a grounded prompt
4. Bedrock generates the answer
5. frontend displays answer and citations

---

## Quick Start

### 1. Clone Repo
```bash
git clone https://github.com/your-username/ecommerce-support-chatbot.git
cd ecommerce-support-chatbot
```

### 2. Configure Terraform
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit values
```

### 3. Deploy Infrastructure
```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. Build and Push Images
```bash
cd ..
chmod +x scripts/*.sh
./scripts/build-and-push.sh
```

### 5. Deploy Services and Load Data
```bash
./scripts/deploy.sh
```

### 6. Validate
```bash
./scripts/health-check.sh
```

---

## Demo Usage

Example questions:
- What is your shipping policy?
- How do returns work?
- What payment methods do you accept?
- Can I cancel my order?
- Track my order ORD-123456

---

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Deployment Guide](docs/DEPLOYMENT-GUIDE.md)
- [Runbook](docs/RUNBOOK.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Data Model](docs/DATA-MODEL.md)
- [API Reference](docs/API-REFERENCE.md)
- [Responsible AI](docs/RESPONSIBLE-AI.md)
- [Production Checklist](docs/PRODUCTION-CHECKLIST.md)

### ADRs
- [ADR-001 Bedrock](docs/adrs/001-use-amazon-bedrock.md)
- [ADR-002 OpenSearch](docs/adrs/002-use-opensearch-for-rag.md)
- [ADR-003 ECS Fargate](docs/adrs/003-use-ecs-fargate.md)
- [ADR-004 DynamoDB](docs/adrs/004-use-dynamodb-for-sessions.md)
- [ADR-005 RAG Pattern](docs/adrs/005-use-rag-pattern.md)

---

## Project Structure

```text
ecommerce-support-chatbot/
├── terraform/
├── backend/
├── frontend/
├── workers/
├── scripts/
├── docs/
└── diagrams/
```

---

## Current Scope

### Included
- full Terraform infrastructure
- frontend chat UI
- backend orchestration
- Bedrock integration
- OpenSearch-based RAG
- DynamoDB session handling
- FAQ ingestion worker
- CloudWatch monitoring
- runbook and troubleshooting docs
- ADR pack
- Mermaid diagrams

### Not Included Yet
- Cognito authentication
- real OMS integration
- Bedrock Guardrails
- CI/CD pipeline
- multi-region production architecture

---

## Technology Stack

- Terraform
- AWS
- Amazon Bedrock
- Amazon OpenSearch Service
- Amazon ECS Fargate
- Amazon CloudFront
- Amazon S3
- Amazon DynamoDB
- AWS Secrets Manager
- Amazon CloudWatch
- FastAPI
- Python
- React
- TypeScript
- Docker

---

## Security Notes

Current implementation includes:
- VPC isolation
- private subnets
- IAM roles
- Secrets Manager
- encryption at rest
- TLS in transit
- input sanitization
- basic PII detection

For production hardening, see:
- [SECURITY.md](SECURITY.md)
- [Production Checklist](docs/PRODUCTION-CHECKLIST.md)
- [Responsible AI](docs/RESPONSIBLE-AI.md)

---

## Contact
**AbuTalha**
- LinkedIn: [Im-AbuTalha](https://linkedin.com/in/Im-AbuTalha)
- GitHub: [LearningGallery](https://github.com/LearningGallery)

---

## License

MIT