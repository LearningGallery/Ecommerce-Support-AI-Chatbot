from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum


class MessageRole(str, Enum):
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class ChatMessage(BaseModel):
    role: MessageRole
    content: str
    timestamp: Optional[datetime] = None
    metadata: Optional[Dict[str, Any]] = None


class SourceCitation(BaseModel):
    content: str
    source: str
    score: float
    metadata: Optional[Dict[str, Any]] = None


class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=4000)
    session_id: Optional[str] = None
    user_id: Optional[str] = "anonymous"
    use_rag: bool = True
    include_history: bool = True


class ChatResponse(BaseModel):
    session_id: str
    message: str
    sources: Optional[List[SourceCitation]] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    metadata: Optional[Dict[str, Any]] = None


class HealthResponse(BaseModel):
    status: str
    version: str = "1.0.0"
    services: Dict[str, str]