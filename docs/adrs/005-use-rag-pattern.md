# ADR-005: Use RAG Pattern for Grounded Responses

## Status
Accepted

## Context
Direct prompting alone increases hallucination risk and does not ground answers in business knowledge.

## Decision
Use retrieval-augmented generation (RAG).

## Rationale
- grounds answers in FAQ/policy documents
- improves transparency with citations
- easier to update knowledge than fine-tuning

## Consequences
### Positive
- lower hallucination risk
- improved trust and explainability

### Negative
- additional retrieval latency
- requires ingestion/index maintenance

## Alternatives Considered
- direct prompting only
- fine-tuning only

## Production Recommendation
Add semantic retrieval, evaluation, and prompt injection defenses.