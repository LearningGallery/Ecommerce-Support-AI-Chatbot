import logging
from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import JSONResponse
from models.chat_models import ChatRequest, ChatResponse, HealthResponse
from models.session_models import SessionCreate, SessionResponse
from services.chat_service import ChatService
from services.session_service import SessionService
from services.llm_service import BedrockLLMService
from services.retrieval_service import OpenSearchRetrievalService
from api.dependencies import verify_api_key

logger = logging.getLogger(__name__)

router = APIRouter()

chat_service = ChatService()
session_service = SessionService()
llm_service = BedrockLLMService()
retrieval_service = OpenSearchRetrievalService()


@router.get("/health", response_model=HealthResponse)
async def health_check():
    services_status = {
        "bedrock": "unknown",
        "opensearch": "unknown",
        "dynamodb": "healthy"
    }

    try:
        services_status["bedrock"] = "healthy" if llm_service.health_check() else "unhealthy"
    except Exception as e:
        logger.error(f"Bedrock health check error: {str(e)}")
        services_status["bedrock"] = "unhealthy"

    try:
        services_status["opensearch"] = "healthy" if retrieval_service.health_check() else "unhealthy"
    except Exception as e:
        logger.error(f"OpenSearch health check error: {str(e)}")
        services_status["opensearch"] = "unhealthy"

    overall_status = "healthy" if all(
        status == "healthy" for status in services_status.values()
    ) else "degraded"

    return HealthResponse(
        status=overall_status,
        services=services_status
    )


@router.post("/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    api_key: str = Depends(verify_api_key)
):
    try:
        logger.info(f"Processing chat request for user: {request.user_id}")
        response = await chat_service.process_chat(request)
        return response
    except Exception as e:
        logger.error(f"Error processing chat: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to process chat request")


@router.post("/sessions", response_model=SessionResponse)
async def create_session(
    session_data: SessionCreate,
    api_key: str = Depends(verify_api_key)
):
    try:
        session_id = await session_service.create_session(
            user_id=session_data.user_id,
            metadata=session_data.metadata
        )

        session = await session_service.get_session(session_id)
        if not session:
            raise HTTPException(status_code=500, detail="Session created but could not be retrieved")

        return SessionResponse(
            session_id=session.session_id,
            user_id=session.user_id,
            message_count=len(session.messages),
            created_at=session.created_at,
            updated_at=session.updated_at
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating session: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to create session")


@router.get("/sessions/{session_id}", response_model=SessionResponse)
async def get_session(
    session_id: str,
    api_key: str = Depends(verify_api_key)
):
    try:
        session = await session_service.get_session(session_id)

        if not session:
            raise HTTPException(status_code=404, detail="Session not found")

        return SessionResponse(
            session_id=session.session_id,
            user_id=session.user_id,
            message_count=len(session.messages),
            created_at=session.created_at,
            updated_at=session.updated_at
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving session: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to retrieve session")


@router.delete("/sessions/{session_id}")
async def delete_session(
    session_id: str,
    api_key: str = Depends(verify_api_key)
):
    try:
        success = await session_service.delete_session(session_id)

        if not success:
            raise HTTPException(status_code=404, detail="Session not found")

        return JSONResponse(
            status_code=200,
            content={"message": "Session deleted successfully"}
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting session: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="Failed to delete session")