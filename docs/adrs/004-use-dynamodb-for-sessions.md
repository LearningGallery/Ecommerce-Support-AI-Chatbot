# ADR-004: Use DynamoDB for Session Storage

## Status
Accepted

## Context
The chatbot needs lightweight session persistence for conversation history.

## Decision
Use DynamoDB.

## Rationale
- low operational overhead
- TTL support
- fast key-value access
- cost-efficient for demo workloads

## Consequences
### Positive
- simple session handling
- no relational database management required

### Negative
- less flexible querying than relational databases
- embedded message arrays may not scale for very large histories

## Alternatives Considered
- RDS PostgreSQL
- ElastiCache
- S3-based persistence

## Production Recommendation
Consider separate message records or relational storage if analytics/query needs grow.