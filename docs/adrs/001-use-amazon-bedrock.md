# ADR-001: Use Amazon Bedrock for LLM Integration

## Status
Accepted

## Context
The solution requires an AWS-native managed LLM service for chatbot inference.

## Decision
Use Amazon Bedrock with Claude 3.5 Sonnet as the default model.

## Rationale
- AWS-native managed service
- no model hosting overhead
- strong model quality
- security and IAM integration
- suitable for portfolio and enterprise reference architecture

## Consequences
### Positive
- simpler operations
- no GPU infrastructure
- easy integration with backend

### Negative
- dependent on Bedrock availability and model access
- model access may require enablement in account

## Alternatives Considered
- self-hosted open-source model on EC2/EKS
- third-party external API

## Production Recommendation
Add Bedrock Guardrails and model fallback strategy.