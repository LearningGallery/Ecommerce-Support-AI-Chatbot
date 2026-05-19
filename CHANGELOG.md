# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- Initial release of E-Commerce Customer Support AI Chatbot
- Complete Terraform infrastructure for AWS deployment
- FastAPI backend with Bedrock integration
- React TypeScript frontend with modern UI
- RAG pattern implementation with OpenSearch
- DynamoDB session management
- S3 document storage
- CloudFront CDN distribution
- ECS Fargate container orchestration
- Comprehensive documentation (8 guides + 5 ADRs)
- Deployment automation scripts
- Sample FAQ data and ingestion pipeline
- CloudWatch monitoring and logging
- Security best practices (VPC, IAM, encryption)

### Infrastructure
- VPC with public/private subnets across 2 AZs
- Application Load Balancers for frontend and backend
- ECS Fargate services with auto-scaling
- OpenSearch domain for knowledge base
- DynamoDB tables with TTL
- S3 buckets with versioning
- CloudFront distribution with optional WAF
- ECR repositories for container images
- Secrets Manager for credential storage
- CloudWatch dashboards and alarms

### Features
- Interactive chat interface
- Real-time message display
- Source citation from knowledge base
- Session persistence with 24-hour TTL
- Order status lookup (mock)
- FAQ search with relevance scoring
- PII detection and blocking
- Input sanitization
- Health check endpoints
- CORS support

### Documentation
- Complete architecture documentation
- Step-by-step deployment guide
- Operations runbook
- Troubleshooting guide
- Data model documentation
- 5 Architecture Decision Records
- 6 Mermaid diagrams
- draw.io blueprint guide
- Premium README with badges

## [Unreleased]

### Planned
- User authentication with Cognito
- Vector embeddings for semantic search
- Streaming responses
- Multi-language support
- Advanced analytics dashboard
- CI/CD pipeline
- Blue-green deployment
- A/B testing framework