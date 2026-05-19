# Troubleshooting Guide

## 1. Backend Health Endpoint Returns Degraded

### Symptoms
- `/api/v1/health` returns `degraded`

### Likely Causes
- Bedrock access issue
- OpenSearch unavailable
- backend env vars incorrect

### Actions
1. Check backend logs
2. verify Bedrock model access
3. verify OpenSearch endpoint and credentials
4. verify ECS task role permissions

---

## 2. Frontend Loads But Chat Fails

### Symptoms
- UI opens
- sending message returns error

### Likely Causes
- backend API unreachable
- CORS issue
- backend task unhealthy

### Actions
1. test backend ALB directly
2. inspect browser dev tools
3. inspect backend logs
4. verify `VITE_API_ENDPOINT`

---

## 3. Empty Responses

### Symptoms
- chatbot returns fallback often
- little or no useful answer

### Likely Causes
- no indexed data
- retrieval score too strict
- prompt context empty

### Actions
1. run sample search against OpenSearch
2. confirm FAQ data loaded
3. reduce relevance threshold if needed
4. inspect retrieval logs

---

## 4. Hallucinated Responses

### Symptoms
- chatbot invents unsupported answers

### Likely Causes
- insufficient grounding
- direct prompting without retrieval
- FAQ data too vague

### Actions
1. strengthen prompt instructions
2. ensure RAG is enabled
3. improve FAQ content specificity
4. reduce context noise

---

## 5. OpenSearch Connection Errors

### Symptoms
- backend logs show OpenSearch connection error

### Likely Causes
- wrong endpoint
- wrong credentials
- SG/network issue
- domain still provisioning

### Actions
1. verify domain is active
2. verify Secrets Manager contents
3. confirm ECS can reach OpenSearch over 443
4. verify VPC/subnet/security groups

---

## 6. Bedrock Access Denied

### Symptoms
- backend logs show `AccessDeniedException`

### Likely Causes
- model access not granted
- task role missing permissions

### Actions
1. enable model access in Bedrock console
2. verify IAM task role policy includes:
   - `bedrock:InvokeModel`
   - `bedrock:InvokeModelWithResponseStream`

---

## 7. ECS Tasks Keep Restarting

### Symptoms
- service unstable
- tasks stop repeatedly

### Likely Causes
- app startup error
- missing environment variables
- health check failure
- image issue

### Actions
1. inspect task stopped reason
2. inspect CloudWatch logs
3. verify Docker image and container startup
4. verify health endpoint path

---

## 8. CloudFront Returns 403 or 404

### Symptoms
- frontend inaccessible
- API path not routing

### Likely Causes
- origin misconfiguration
- CloudFront cache issue
- static routing issue

### Actions
1. verify ALB origins
2. invalidate CloudFront cache
3. verify SPA fallback behavior
4. verify ordered cache behaviors

---

## 9. FAQ Data Not Appearing

### Symptoms
- search returns no results
- chatbot cannot answer FAQ questions

### Likely Causes
- ingestion script not run
- index missing
- data format issue

### Actions
1. run `./scripts/init-opensearch.sh`
2. run `./scripts/load-sample-data.sh`
3. inspect ingestion logs
4. validate document count

---

## 10. DynamoDB Session Problems

### Symptoms
- session not found
- history missing
- session delete not working

### Likely Causes
- key design mismatch
- scan fallback logic needed
- TTL expiration

### Actions
1. inspect table items
2. confirm session ID values
3. review backend session service logic
4. verify TTL not expiring too quickly

---

## 11. Secret Rotation Broke Backend

### Symptoms
- backend cannot connect to OpenSearch after secret update

### Likely Causes
- ECS task still using old secret version
- wrong JSON key names

### Actions
1. verify secret JSON keys:
   - `opensearch_endpoint`
   - `opensearch_username`
   - `opensearch_password`
2. force ECS redeployment
3. validate backend logs

---

## 12. Deployment Fails During Terraform Apply

### Symptoms
- Terraform apply errors

### Likely Causes
- missing IAM permissions
- service quota issues
- invalid regional support
- naming collision

### Actions
1. inspect exact Terraform error
2. verify region supports services
3. verify account quotas
4. update names or random suffix handling

---

## 13. Quick Diagnostic Commands

### Backend Health
```bash
curl http://<backend-alb-dns>/api/v1/health
```

### ECS Service State
```bash
aws ecs describe-services --cluster <cluster> --services <service>
```

### ECS Task Logs
```bash
aws logs tail /ecs/ecommerce-chatbot-dev/backend --follow
```

### OpenSearch Count
```bash
curl -u admin:<password> https://<opensearch-endpoint>/ecommerce-faq/_count
```

### DynamoDB Scan
```bash
aws dynamodb scan --table-name ecommerce-chatbot-dev-sessions
```
