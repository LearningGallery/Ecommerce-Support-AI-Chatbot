# Responsible AI Notes

## 1. Purpose

This document describes responsible AI considerations for the E-Commerce Customer Support AI Chatbot.

The chatbot is intended to:
- answer FAQ and policy questions
- provide basic order help
- reduce repetitive support load
- improve customer experience

It is **not** intended to:
- provide legal advice
- make financial decisions
- replace human escalation for complex cases
- make policy exceptions without human approval

---

## 2. Responsible AI Principles Applied

### Accuracy
The chatbot should answer based on:
- indexed FAQ and policy documents
- explicit system prompt instructions
- retrieved context from OpenSearch

### Transparency
The chatbot should:
- present source citations where possible
- avoid pretending to know information it does not have
- clearly indicate when a human agent is needed

### Safety
The chatbot should:
- avoid unsafe or misleading content
- reject unsupported claims
- avoid processing or encouraging sharing of sensitive personal data

### Privacy
The chatbot should:
- minimize storage of personal data
- detect obvious PII patterns
- avoid logging secrets or sensitive content unnecessarily

### Human Oversight
The chatbot should:
- defer to human support for ambiguous or sensitive issues
- use fallback responses when confidence is low
- not act as a final authority for exceptions or disputes

---

## 3. Known Risks

### Hallucination
LLMs may generate plausible but incorrect responses.

Mitigations:
- RAG grounding
- prompt instructions to answer only from context
- fallback response when context is insufficient
- source citations

### Prompt Injection
Users may attempt to manipulate the model to ignore instructions.

Mitigations:
- system prompt precedence
- input sanitization
- retrieval-only grounding pattern
- production recommendation: Bedrock Guardrails or external filters

### Data Leakage
Sensitive data may appear in user prompts or logs.

Mitigations:
- basic PII detection
- no secrets in code
- Secrets Manager usage
- production recommendation: log redaction and DLP

### Over-Reliance
Users may trust the chatbot too much.

Mitigations:
- explicit fallback language
- escalation recommendation
- source citation visibility

---

## 4. Current Safety Controls

- input sanitization
- basic PII detection
- fallback responses
- context grounding
- no unsupported answer policy in prompt
- limited scope of domain knowledge
- no autonomous action execution

---

## 5. Current Limitations

1. No dedicated moderation service
2. No Bedrock Guardrails configured
3. No formal confidence scoring
4. No human handoff integration
5. No red-team evaluation pipeline
6. No automated hallucination benchmarking

---

## 6. Production Recommendations

- enable Bedrock Guardrails where available
- add content moderation layer
- add prompt injection detection
- implement confidence / retrieval quality scoring
- add human escalation workflow
- implement evaluation datasets and regression tests
- add business rule validation before returning sensitive answers

---

## 7. Example Safe Response Patterns

### When context is missing
> I don’t have specific information about that in our knowledge base. Please contact our support team for help.

### When order data is unavailable
> I’m unable to verify that order right now. Please contact support with your order number for assistance.

### When user shares sensitive information
> For your security, please do not share personal or payment information in chat.

---

## 8. Governance Recommendations

For production governance:
- define approved use cases
- define disallowed use cases
- document model selection rationale
- document data retention rules
- review prompts regularly
- review logs and failure cases regularly
- maintain ADRs for AI decisions