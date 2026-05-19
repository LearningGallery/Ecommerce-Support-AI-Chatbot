# ADR-002: Use OpenSearch for RAG Retrieval

## Status
Accepted

## Context
The chatbot needs a searchable knowledge base for FAQ and policy retrieval.

## Decision
Use Amazon OpenSearch Service.

## Rationale
- managed search platform
- strong text retrieval capabilities
- future extensibility to vector search
- suitable for FAQ retrieval use case

## Consequences
### Positive
- scalable retrieval layer
- good fit for RAG
- supports structured metadata

### Negative
- more expensive than very lightweight alternatives
- provisioning time is longer than serverless services

## Alternatives Considered
- DynamoDB-only lookup
- Aurora PostgreSQL with pgvector
- external vector database

## Production Recommendation
Use multi-AZ deployment and lifecycle/index management.