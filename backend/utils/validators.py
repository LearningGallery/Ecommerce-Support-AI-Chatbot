import re
from typing import Optional


def sanitize_input(text: str) -> str:
    """
    Sanitize user input to prevent injection attacks.
    """
    text = re.sub(r'<script[^>]*>.*?</script>', '', text, flags=re.DOTALL | re.IGNORECASE)
    text = re.sub(r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|EXECUTE)\b)', '', text, flags=re.IGNORECASE)
    text = text[:4000]
    text = ' '.join(text.split())
    return text.strip()


def is_greeting(message: str) -> bool:
    greetings = ['hello', 'hi', 'hey', 'greetings', 'good morning', 'good afternoon', 'good evening']
    message_lower = message.lower().strip()
    return any(greeting in message_lower for greeting in greetings) and len(message.split()) <= 5


def is_order_inquiry(message: str) -> bool:
    order_keywords = ['order', 'tracking', 'shipment', 'delivery', 'package', 'order number', 'track my']
    message_lower = message.lower()
    return any(keyword in message_lower for keyword in order_keywords)


def extract_order_number(message: str) -> Optional[str]:
    patterns = [
        r'(?:ORD-|ORDER-|#)(\d{4,10})',
        r'order\s+(?:number\s+)?(\d{4,10})',
        r'\b(\d{8,10})\b'
    ]

    for pattern in patterns:
        match = re.search(pattern, message, re.IGNORECASE)
        if match:
            return match.group(1)

    return None


def contains_pii(text: str) -> bool:
    if re.search(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', text):
        return True

    if re.search(r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b', text):
        return True

    if re.search(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b', text):
        return True

    return False


def validate_session_id(session_id: str) -> bool:
    pattern = r'^[a-zA-Z0-9-]{20,50}$'
    return bool(re.match(pattern, session_id))