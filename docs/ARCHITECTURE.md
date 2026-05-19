# Architecture Documentation

## 1. Overview

The **E-Commerce Customer Support AI Chatbot** is an AWS-native, containerized AI application that provides customer support for:
- FAQ queries
- shipping and returns questions
- payment and account questions
- order help and order tracking
- policy clarification

The solution is designed for:
- GitHub portfolio showcase
- AWS / AI architecture demonstration
- reusable reference implementation
- low-cost sandbox or demo deployment

---

## 2. Objectives

### Business Objectives
- Demonstrate a realistic customer support chatbot for e-commerce
- Show how LLMs can be integrated into AWS-native applications
- Provide a reusable reference architecture for learning and portfolio use
- Keep the solution understandable to technical and non-technical readers

### Technical Objectives
- Build an end-to-end chatbot with frontend, backend, and AI integration
- Use Terraform for reproducible infrastructure deployment
- Support RAG with a knowledge base
- Provide observability, operational guidance, and security documentation
- Use cost-conscious AWS services suitable for a personal/sandbox account

---

## 3. Assumptions

- AWS region is `ap-southeast-1` by default
- Amazon Bedrock access is enabled in the AWS account
- The deployment target is primarily a demo or learning environment
- IAM permissions may be limited in some personal/sandbox accounts
- The chatbot knowledge base is based on preloaded FAQ/policy content
- Order lookup is mocked for demo purposes unless replaced with a real order system

---

## 4. In Scope

- Web-based chatbot frontend
- Backend orchestration service
- Amazon Bedrock LLM integration
- OpenSearch-backed knowledge retrieval
- DynamoDB-based session persistence
- S3-based document storage
- ECS Fargate deployment
- CloudFront distribution
- CloudWatch logs and alarms
- Terraform infrastructure modules
- Documentation, ADRs, diagrams, runbooks

---

## 5. Out of Scope

- Real enterprise SSO integration
- Production-grade ticketing/CRM integration
- Full customer identity and authorization model
- Real OMS/WMS/ERP integration
- Multi-region HA and DR
- Full CI/CD implementation
- Advanced red teaming and AI evaluation pipelines
- Dedicated human handoff workflow

---

## 6. High-Level Architecture

### Summary
The solution uses:
- **React** frontend for chat UI
- **FastAPI** backend for orchestration
- **Amazon Bedrock** for LLM inference
- **Amazon OpenSearch Service** for FAQ/policy retrieval
- **Amazon DynamoDB** for chat sessions
- **Amazon S3** for FAQ and static asset storage
- **Amazon ECS Fargate** for containerized deployment
- **Amazon CloudFront** for edge delivery
- **Amazon CloudWatch** for logs, metrics, alarms

### Architecture Pattern
This solution follows a **RAG-based chatbot architecture**:
1. User sends a query from the frontend
2. Backend receives and sanitizes the request
3. Backend optionally retrieves relevant documents from OpenSearch
4. Backend constructs a prompt using retrieved context
5. Backend calls Bedrock to generate a grounded answer
6. Backend stores conversation history in DynamoDB
7. Frontend displays the answer and optional citations

---

## 7. High-Level Design (HLD)

### Major Components

| Layer | Component | AWS Service / Tech |
|------|-----------|--------------------|
| Presentation | Chat UI | React, Nginx, ECS Fargate |
| Edge | CDN | CloudFront |
| API | Chat API | FastAPI on ECS Fargate |
| Orchestration | Chat service | Python service layer |
| AI | LLM inference | Amazon Bedrock |
| Retrieval | Knowledge base search | OpenSearch |
| Session Store | Chat sessions | DynamoDB |
| Object Storage | Documents / static files | S3 |
| Secrets | Credentials | Secrets Manager |
| Monitoring | Logs, metrics, alarms | CloudWatch |

### Design Rationale
- **ECS Fargate** chosen for serverless containers and simplified operations
- **Bedrock** chosen for AWS-native LLM integration
- **OpenSearch** chosen for scalable text retrieval and future vector extensibility
- **DynamoDB** chosen for simple, cost-efficient session persistence
- **CloudFront** chosen for performance and secure frontend delivery

---

## 8. Low-Level Design (LLD)

### Frontend
- React SPA
- Calls backend `/api/v1/chat`
- Displays:
  - user messages
  - assistant responses
  - loading indicator
  - source citations
  - error messages

### Backend
- FastAPI app with:
  - `/api/v1/chat`
  - `/api/v1/sessions`
  - `/api/v1/health`
- Service layer:
  - `ChatService`
  - `BedrockLLMService`
  - `OpenSearchRetrievalService`
  - `SessionService`
  - `OrderService`

### Retrieval
- OpenSearch index: `ecommerce-faq`
- Search fields:
  - `content`
  - `title`
  - `category`

### Session Persistence
- DynamoDB session record stores:
  - session metadata
  - messages
  - timestamps
  - TTL

---

## 9. AI System Architecture

### AI Capabilities
- FAQ answering
- policy explanation
- order help
- contextual follow-up responses
- source-grounded answers using retrieved FAQ content

### Prompt Orchestration
1. Detect simple greeting or order inquiry
2. If order inquiry with order number:
   - use order lookup flow
3. Else if RAG enabled:
   - retrieve top relevant FAQ documents
   - build prompt with context
4. Invoke Bedrock model
5. Return formatted answer with citations

### Model Choice
Default model:
- `anthropic.claude-3-5-sonnet-20241022-v2:0`

Reason:
- strong conversational quality
- good instruction following
- suitable for support use cases
- available through Bedrock

---

## 10. Runtime Architecture

### Request Lifecycle
1. User accesses frontend through CloudFront
2. Frontend sends request to backend ALB
3. Backend ECS task receives request
4. Backend validates and sanitizes input
5. Backend retrieves session history from DynamoDB
6. Backend queries OpenSearch for relevant context
7. Backend invokes Bedrock
8. Backend stores response in DynamoDB
9. Frontend renders answer

---

## 11. Deployment Architecture

### Core AWS Resources
- VPC
- Public subnets
- Private subnets
- Internet Gateway
- NAT Gateway
- ECS Cluster
- ECS Services
- ALBs
- OpenSearch domain
- DynamoDB tables
- S3 buckets
- CloudFront distribution
- Secrets Manager secret
- CloudWatch dashboard and alarms

### Deployment Method
- Terraform provisions infrastructure
- Docker builds frontend and backend images
- Images pushed to ECR
- ECS services updated with latest images
- Ingestion script loads FAQ documents into OpenSearch

---

## 12. Component-to-Service Mapping

| Logical Component | Implementation |
|-------------------|----------------|
| Chat UI | React |
| Frontend hosting | ECS Fargate + ALB + CloudFront |
| Chat API | FastAPI |
| Orchestration | Python service layer |
| LLM | Amazon Bedrock |
| FAQ retrieval | OpenSearch |
| Session persistence | DynamoDB |
| Document store | S3 |
| Secrets | Secrets Manager |
| Logs and metrics | CloudWatch |

---

## 13. Chatbot Interaction Flow

### Supported Questions
The chatbot can answer:
- shipping policy questions
- return and refund questions
- payment method questions
- warranty questions
- cancellation policy questions
- account creation questions
- order tracking and order status questions

### Knowledge Sources
- FAQ JSON documents loaded into OpenSearch
- optional order lookup from mock order service
- prompt/system instructions

### Session Handling
- session ID created when chat begins
- stored in DynamoDB
- previous messages included optionally in prompt context
- TTL used to auto-expire sessions

---

## 14. RAG Flow

### Retrieval Flow
1. Receive user question
2. Query OpenSearch using multi-match search
3. Filter by relevance score
4. Select top documents
5. Build context block
6. Inject context into RAG prompt template
7. Send prompt to Bedrock
8. Return answer with citations

### Hallucination Mitigation
- instruct the model to answer only from context
- fallback response when no relevant context is found
- include citations for transparency
- avoid unsupported claims
- keep retrieval scope narrow to domain FAQ content

---

## 15. Security Overview

### Current Security Controls
- VPC isolation
- private subnets for ECS tasks and OpenSearch
- security groups
- encryption at rest
- TLS in transit
- Secrets Manager for credentials
- input sanitization
- basic PII detection
- optional WAF
- IAM roles for ECS tasks

### Current Demo Limitations
1. **Authentication**
   - Limitation: no real user authentication
   - Workaround: demo access without login
   - Production recommendation: Amazon Cognito or enterprise IdP

2. **Order System Integration**
   - Limitation: mock order lookup
   - Workaround: static demo order responses
   - Production recommendation: integrate with OMS via secure API

3. **Fine-grained Authorization**
   - Limitation: no RBAC
   - Workaround: single-user demo model
   - Production recommendation: role-based access with JWT claims

4. **Advanced AI Safety**
   - Limitation: no external guardrail service
   - Workaround: prompt constraints + validation + fallback
   - Production recommendation: Bedrock Guardrails / custom moderation pipeline

---

## 16. Observability

### Logging
- Backend logs in CloudWatch
- Frontend logs in CloudWatch
- VPC Flow Logs enabled
- OpenSearch logs enabled

### Metrics
- ECS CPU / Memory
- ALB response time
- OpenSearch cluster health
- request counts

### Alarms
- backend CPU high
- backend memory high
- OpenSearch red state
- unhealthy targets

---

## 17. Operational Model

### Build
- Docker build for frontend and backend

### Deploy
- Terraform for infrastructure
- shell scripts for image push and ECS rollout

### Operate
- use CloudWatch dashboard
- inspect logs
- run health checks
- reload FAQ data when required

### Support
- runbook and troubleshooting guide provided
- ADRs document major architectural choices

---

## 18. Cost Optimization Notes

### Demo-Friendly Choices
- small OpenSearch instance
- Fargate instead of EKS
- DynamoDB on-demand
- single environment
- optional WAF disabled by default

### Production Recommendations
- use multi-AZ OpenSearch
- tighten CORS
- enable WAF
- use Cognito
- implement proper CI/CD
- use real order APIs
- consider Bedrock Guardrails
- add backup and DR strategy

---

## 19. Production Hardening Recommendations

- enable AWS WAF
- implement Cognito authentication
- restrict CORS to known domains
- use ACM + custom domain
- add CloudTrail and GuardDuty
- enable Config rules
- add autoscaling policies tuned by load testing
- implement backup/restore validation
- add CI/CD pipeline with approvals
- add canary or blue/green deployment
- implement structured application metrics

---

## 20. Conclusion

This architecture provides a realistic, portfolio-ready reference implementation of an AI chatbot on AWS. It balances:
- simplicity
- realism
- cost awareness
- extensibility
- professional documentation

It is suitable as:
- a learning project
- a demo deployment
- a GitHub showcase
- a reusable baseline for future production systems