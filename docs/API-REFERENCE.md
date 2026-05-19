# API Reference

## Base Path

```text
/api/v1
```

---

## 1. Health Check

### GET `/health`

Returns service health.

### Example Request
```bash
curl http://<backend-alb-dns>/api/v1/health
```

### Example Response
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "services": {
    "bedrock": "healthy",
    "opensearch": "healthy",
    "dynamodb": "healthy"
  }
}
```

---

## 2. Create Session

### POST `/sessions`

Creates a new chat session.

### Request Body
```json
{
  "user_id": "anonymous",
  "metadata": {
    "channel": "web"
  }
}
```

### Example Response
```json
{
  "session_id": "7f2d8f11-6f9b-4c66-8e5f-123456789abc",
  "user_id": "anonymous",
  "message_count": 0,
  "created_at": "2024-01-15T10:00:00.000000",
  "updated_at": "2024-01-15T10:00:00.000000"
}
```

---

## 3. Get Session

### GET `/sessions/{session_id}`

Returns session summary.

### Example Request
```bash
curl http://<backend-alb-dns>/api/v1/sessions/<session_id>
```

### Example Response
```json
{
  "session_id": "7f2d8f11-6f9b-4c66-8e5f-123456789abc",
  "user_id": "anonymous",
  "message_count": 4,
  "created_at": "2024-01-15T10:00:00.000000",
  "updated_at": "2024-01-15T10:05:00.000000"
}
```

---

## 4. Delete Session

### DELETE `/sessions/{session_id}`

Deletes a session.

### Example Response
```json
{
  "message": "Session deleted successfully"
}
```

---

## 5. Chat Endpoint

### POST `/chat`

Processes a chat message.

### Request Body
```json
{
  "message": "What is your shipping policy?",
  "session_id": "7f2d8f11-6f9b-4c66-8e5f-123456789abc",
  "user_id": "anonymous",
  "use_rag": true,
  "include_history": true
}
```

### Example Response
```json
{
  "session_id": "7f2d8f11-6f9b-4c66-8e5f-123456789abc",
  "message": "We offer free standard shipping on orders over $50. Standard shipping takes 5-7 business days. Express shipping is available for $15.\n\nIs there anything else I can help you with today?",
  "sources": [
    {
      "content": "We offer free standard shipping on orders over $50. Standard shipping takes 5-7 business days...",
      "source": "Shipping: Shipping Policy",
      "score": 1.23,
      "metadata": {
        "source": "shipping_policy",
        "chunk_index": 0,
        "total_chunks": 1
      }
    }
  ],
  "timestamp": "2024-01-15T10:05:00.000000",
  "metadata": null
}
```

---

## 6. Error Responses

### 400 / 422 Validation Error
```json
{
  "detail": [
    {
      "type": "string_too_short",
      "loc": ["body", "message"],
      "msg": "String should have at least 1 character"
    }
  ]
}
```

### 500 Internal Error
```json
{
  "detail": "Failed to process chat request"
}
```

---

## 7. Authentication

Current demo state:
- no enforced user authentication
- optional placeholder API key header

Production recommendation:
- Cognito / JWT / OAuth2
- role-based authorization
- admin-only ingestion endpoints