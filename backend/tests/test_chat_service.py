import pytest
from unittest.mock import AsyncMock, patch
from services.chat_service import ChatService
from models.chat_models import ChatRequest


@pytest.mark.asyncio
async def test_process_greeting():
    service = ChatService()
    service.session_service.create_session = AsyncMock(return_value="test-session")
    service.session_service.add_message = AsyncMock(return_value=True)

    request = ChatRequest(message="hello")
    response = await service.process_chat(request)

    assert response.session_id == "test-session"
    assert response.message is not None
    assert len(response.message) > 0


@pytest.mark.asyncio
async def test_process_pii_block():
    service = ChatService()
    request = ChatRequest(message="My email is test@example.com")

    response = await service.process_chat(request)

    assert "please don't share personal information" in response.message.lower()