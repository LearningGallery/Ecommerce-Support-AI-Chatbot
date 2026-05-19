# Operations Runbook

## 1. Purpose

This runbook provides operational guidance for running, monitoring, and supporting the E-Commerce Customer Support AI Chatbot.

---

## 2. Daily Checks

### Health Check
```bash
./scripts/health-check.sh
```

### Review ECS Services
```bash
aws ecs describe-services \
  --cluster <cluster-name> \
  --services <backend-service> <frontend-service>
```

### Review CloudWatch Logs
```bash
aws logs tail /ecs/ecommerce-chatbot-dev/backend --follow
```

### Review CloudWatch Dashboard
Open the dashboard from Terraform output or AWS Console.

---

## 3. Core Operational Tasks

### Restart Backend Service
```bash
aws ecs update-service \
  --cluster <cluster-name> \
  --service <backend-service> \
  --force-new-deployment
```

### Restart Frontend Service
```bash
aws ecs update-service \
  --cluster <cluster-name> \
  --service <frontend-service> \
  --force-new-deployment
```

### Scale Backend Service
```bash
aws ecs update-service \
  --cluster <cluster-name> \
  --service <backend-service> \
  --desired-count 3
```

### Scale Frontend Service
```bash
aws ecs update-service \
  --cluster <cluster-name> \
  --service <frontend-service> \
  --desired-count 3
```

---

## 4. Log Inspection

### Backend Logs
```bash
aws logs tail /ecs/ecommerce-chatbot-dev/backend --since 1h
```

### Frontend Logs
```bash
aws logs tail /ecs/ecommerce-chatbot-dev/frontend --since 1h
```

### Search Errors
```bash
aws logs filter-log-events \
  --log-group-name /ecs/ecommerce-chatbot-dev/backend \
  --filter-pattern "ERROR"
```

---

## 5. Validate LLM Connectivity

### Health Endpoint
```bash
curl http://<backend-alb-dns>/api/v1/health
```

Expected:
- Bedrock should show `healthy`

### Manual Bedrock Test
You can also inspect backend logs for Bedrock invocation messages.

---

## 6. Validate Retrieval / Indexing

### Check OpenSearch Index Exists
```bash
curl -u admin:<password> https://<opensearch-endpoint>/ecommerce-faq
```

### Check Document Count
```bash
curl -u admin:<password> https://<opensearch-endpoint>/ecommerce-faq/_count
```

### Run Sample Search
```bash
curl -u admin:<password> \
  -H "Content-Type: application/json" \
  -X POST https://<opensearch-endpoint>/ecommerce-faq/_search \
  -d '{
    "query": {
      "match": {
        "content": "shipping"
      }
    }
  }'
```

---

## 7. FAQ Data Reload

If FAQ data changes:

```bash
./scripts/load-sample-data.sh
```

If index mapping changes:
```bash
./scripts/init-opensearch.sh
./scripts/load-sample-data.sh
```

---

## 8. Troubleshooting Empty Responses

Check:
1. OpenSearch health
2. document count
3. Bedrock health
4. backend logs
5. RAG prompt construction

Fallback behavior should still provide a safe answer if retrieval fails.

---

## 9. Troubleshooting Hallucinated Responses

Check:
- whether RAG is enabled
- whether relevant documents are returned
- whether the prompt tells the model to answer only from context
- whether FAQ content is correct and specific

Mitigation:
- improve prompt grounding
- reduce irrelevant content in index
- add stricter fallback behavior
- lower retrieval ambiguity

---

## 10. Failed Deployment Troubleshooting

### ECS Service Not Stable
Check:
```bash
aws ecs describe-services --cluster <cluster> --services <service>
```

### Task Failures
Check:
```bash
aws ecs list-tasks --cluster <cluster>
aws ecs describe-tasks --cluster <cluster> --tasks <task-arn>
```

### Logs
Inspect CloudWatch logs for:
- import errors
- env var issues
- OpenSearch connection errors
- Bedrock permission errors

---

## 11. Secret Rotation

Update Secrets Manager secret:
```bash
aws secretsmanager update-secret \
  --secret-id <secret-name> \
  --secret-string '{"opensearch_endpoint":"...","opensearch_username":"admin","opensearch_password":"new-password"}'
```

Then redeploy backend:
```bash
aws ecs update-service \
  --cluster <cluster-name> \
  --service <backend-service> \
  --force-new-deployment
```

---

## 12. Model Configuration Changes

If changing Bedrock model:
1. update Terraform variable or environment value
2. redeploy backend ECS service
3. validate `/health`
4. test a chat request

---

## 13. Security Notes

- do not expose OpenSearch publicly beyond intended access
- keep Secrets Manager values out of logs
- avoid storing PII in chat
- restrict CORS in production
- use Cognito or enterprise auth in production
- enable WAF in production

---

## 14. Backup / Recovery Considerations

### Current Demo State
- DynamoDB PITR enabled
- S3 versioning enabled
- OpenSearch snapshots not fully automated in this demo

### Production Recommendation
- scheduled OpenSearch snapshots
- documented restore steps
- backup validation tests
- DR runbook

---

## 15. Operational KPIs

Monitor:
- backend response time
- ECS CPU and memory
- unhealthy target count
- OpenSearch health
- error rate
- Bedrock invocation failures
- retrieval success rate

---

## 16. Escalation Guidance

Escalate if:
- health endpoint remains degraded
- repeated Bedrock failures occur
- OpenSearch becomes unavailable
- ECS tasks continuously restart
- users receive repeated empty responses

Suggested escalation order:
1. application logs
2. ECS service state
3. OpenSearch health
4. Bedrock permissions / service availability
5. infrastructure configuration review