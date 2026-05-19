# Data Model

## 1. Overview

The solution uses:
- DynamoDB for sessions
- OpenSearch for knowledge retrieval
- S3 for documents and static assets

---

## 2. Chat Session Entity

### Storage
DynamoDB table: `ecommerce-chatbot-<env>-sessions`

### Attributes
- `session_id` (PK)
- `timestamp` (SK)
- `user_id`
- `messages`
- `created_at`
- `updated_at`
- `ttl`
- `metadata`

### Rationale
DynamoDB is used because:
- simple key-value access
- low cost
- TTL support
- good fit for demo chat state

---

## 3. Message Entity

Messages are stored as an array inside the session record.

### Message Fields
- `role`
- `content`
- `timestamp`

### Rationale
For demo simplicity, messages are embedded in session records.
Production alternative:
- separate message table
- better analytics and query flexibility

---

## 4. Optional Message Table

A separate DynamoDB table is also provisioned:
- `ecommerce-chatbot-<env>-messages`

### Attributes
- `message_id`
- `session_id`
- `timestamp`
- optional metadata

### Purpose
Can support:
- analytics
- fine-grained audit
- future decoupling from embedded session storage

---

## 5. Document Metadata Entity

### Storage
OpenSearch index: `ecommerce-faq`

### Fields
- `content`
- `title`
- `category`
- `metadata`

### Metadata Example
- `source`
- `chunk_index`
- `total_chunks`

### Rationale
OpenSearch stores FAQ content for retrieval during chat.

---

## 6. Ingestion / Indexing Entity

The ingestion process transforms source FAQ documents into index documents.

### Source FAQ Fields
- `id`
- `title`
- `category`
- `content`
- `source`

### Indexed Fields
- `content`
- `title`
- `category`
- `metadata.chunk_index`
- `metadata.total_chunks`
- `metadata.source`

---

## 7. Citation / Source Mapping

Citations returned to frontend include:
- `content`
- `source`
- `score`
- `metadata`

### Purpose
- transparency
- trust
- explainability
- easier troubleshooting

---

## 8. Storage Rationale

### DynamoDB
Used for:
- sessions
- chat history
- TTL-based cleanup

### OpenSearch
Used for:
- FAQ retrieval
- text search
- future vector extensibility

### S3
Used for:
- source documents
- static assets
- potential backups

---

## 9. Production Considerations

For production:
- separate message records from session record
- add user identity linkage
- add document access controls
- add audit fields
- add encryption / masking for sensitive metadata
- add backup strategy