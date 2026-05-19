# Production Checklist

## Identity & Access
- [ ] Implement Cognito or enterprise SSO
- [ ] Remove demo authentication placeholder
- [ ] Apply least privilege IAM policies
- [ ] Restrict Secrets Manager access
- [ ] Review ECS task role permissions

## Network Security
- [ ] Restrict CORS origins
- [ ] Enable AWS WAF
- [ ] Use custom domain + ACM
- [ ] Review security groups
- [ ] Consider private-only backend access patterns
- [ ] Enable CloudTrail and GuardDuty

## Data Protection
- [ ] Review retention policy for chat sessions
- [ ] Add log redaction for sensitive fields
- [ ] Define data classification
- [ ] Add backup strategy for OpenSearch
- [ ] Validate DynamoDB PITR settings

## AI Safety
- [ ] Add Bedrock Guardrails or moderation layer
- [ ] Add prompt injection testing
- [ ] Add hallucination evaluation dataset
- [ ] Add confidence / retrieval quality thresholds
- [ ] Add human escalation workflow

## Reliability
- [ ] Load test ECS services
- [ ] Tune autoscaling thresholds
- [ ] Use multi-AZ OpenSearch
- [ ] Add synthetic monitoring
- [ ] Add deployment rollback validation

## Observability
- [ ] Add structured JSON logs
- [ ] Add custom application metrics
- [ ] Add alert notification targets
- [ ] Add tracing if needed
- [ ] Review alarm thresholds

## Delivery
- [ ] Add CI/CD pipeline
- [ ] Add Terraform validation in pipeline
- [ ] Add image vulnerability scanning gates
- [ ] Add automated tests
- [ ] Add release versioning strategy

## Governance
- [ ] Review ADRs
- [ ] Review data model
- [ ] Review runbook and troubleshooting docs
- [ ] Define support ownership
- [ ] Define incident response process