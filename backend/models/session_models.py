from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime


class SessionMessage(BaseModel):
    role: str
    content: str
    timestamp: datetime


class ChatSession(BaseModel):
    session_id: str
    user_id: str
    messages: List[SessionMessage]
    created_at: datetime
    updated_at: datetime
    ttl: int
    metadata: Optional[Dict[str, Any]] = None


class SessionCreate(BaseModel):
    user_id: str = "anonymous"
    metadata: Optional[Dict[str, Any]] = None


class SessionResponse(BaseModel):
    session_id: str
    user_id: str
    message_count: int
    created_at: datetime
    updated_at: datetime