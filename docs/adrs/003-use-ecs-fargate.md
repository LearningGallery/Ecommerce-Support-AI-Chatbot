# ADR-003: Use ECS Fargate for Application Hosting

## Status
Accepted

## Context
The frontend and backend need container-based hosting with minimal infrastructure management.

## Decision
Use Amazon ECS Fargate for frontend and backend services.

## Rationale
- no EC2 management
- easy integration with ALB and ECR
- suitable for containerized demo and reference implementation
- simpler than EKS for this use case

## Consequences
### Positive
- operational simplicity
- scalable enough for demo and small workloads

### Negative
- less flexible than Kubernetes for advanced platform patterns
- cost may be higher than EC2 at larger scale

## Alternatives Considered
- EKS
- App Runner
- Lambda