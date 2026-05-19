import logging
import random
from models.chat_models import ChatRequest, ChatResponse, SourceCitation
from services.llm_service import BedrockLLMService
from services.retrieval_service import OpenSearchRetrievalService
from services.session_service import SessionService
from services.order_service import OrderService
from utils.prompt_templates import (
    SYSTEM_PROMPT,
    RAG_PROMPT_TEMPLATE,
    GREETING_RESPONSES,
    FALLBACK_RESPONSES,
    CLOSING_PHRASES
)
from utils.validators import (
    sanitize_input,
    is_greeting,
    is_order_inquiry,
    extract_order_number,
    contains_pii
)

logger = logging.getLogger(__name__)


class ChatService:
    """
    Core orchestration service for chat processing.
    """

    def __init__(self):
        self.llm_service = BedrockLLMService()
        self.retrieval_service = OpenSearchRetrievalService()
        self.session_service = SessionService()
        self.order_service = OrderService()

    async def process_chat(self, request: ChatRequest) -> ChatResponse:
        try:
            user_message = sanitize_input(request.message)

            if contains_pii(user_message):
                logger.warning("PII detected in message")
                return ChatResponse(
                    session_id=request.session_id or "new",
                    message="For your security, please don't share personal information like credit card numbers, phone numbers, or email addresses in the chat. How else can I help you?"
                )

            session_id = request.session_id
            if not session_id:
                session_id = await self.session_service.create_session(user_id=request.user_id)

            await self.session_service.add_message(session_id, "user", user_message)

            if is_greeting(user_message):
                response_message = random.choice(GREETING_RESPONSES)
                await self.session_service.add_message(session_id, "assistant", response_message)
                return ChatResponse(
                    session_id=session_id,
                    message=response_message
                )

            if is_order_inquiry(user_message):
                order_number = extract_order_number(user_message)
                if order_number:
                    response_message = await self._handle_order_inquiry(order_number)
                    await self.session_service.add_message(session_id, "assistant", response_message)
                    return ChatResponse(
                        session_id=session_id,
                        message=response_message
                    )

            if request.use_rag:
                return await self._process_with_rag(
                    session_id=session_id,
                    user_message=user_message,
                    include_history=request.include_history
                )

            return await self._process_without_rag(
                session_id=session_id,
                user_message=user_message,
                include_history=request.include_history
            )

        except Exception as e:
            logger.error(f"Error processing chat: {str(e)}", exc_info=True)
            return ChatResponse(
                session_id=request.session_id or "error",
                message="I apologize, but I encountered an error processing your request. Please try again."
            )

    async def _process_with_rag(
        self,
        session_id: str,
        user_message: str,
        include_history: bool
    ) -> ChatResponse:
        try:
            documents = await self.retrieval_service.search(user_message)

            if not documents:
                response_message = random.choice(FALLBACK_RESPONSES)
                await self.session_service.add_message(session_id, "assistant", response_message)
                return ChatResponse(
                    session_id=session_id,
                    message=response_message
                )

            context = "\n\n".join([
                f"[{doc['category']}] {doc['title']}: {doc['content']}"
                for doc in documents[:3]
            ])

            prompt = RAG_PROMPT_TEMPLATE.format(
                context=context,
                question=user_message
            )

            conversation_history = None
            if include_history:
                conversation_history = await self.session_service.get_conversation_history(session_id)

            response_message = await self.llm_service.generate_response(
                prompt=prompt,
                system_prompt=SYSTEM_PROMPT,
                conversation_history=conversation_history
            )

            response_message += f"\n\n{random.choice(CLOSING_PHRASES)}"

            await self.session_service.add_message(session_id, "assistant", response_message)

            sources = [
                SourceCitation(
                    content=doc["content"][:200] + ("..." if len(doc["content"]) > 200 else ""),
                    source=f"{doc['category']}: {doc['title']}",
                    score=doc["score"],
                    metadata=doc.get("metadata", {})
                )
                for doc in documents[:3]
            ]

            return ChatResponse(
                session_id=session_id,
                message=response_message,
                sources=sources
            )

        except Exception as e:
            logger.error(f"Error in RAG processing: {str(e)}", exc_info=True)
            raise

    async def _process_without_rag(
        self,
        session_id: str,
        user_message: str,
        include_history: bool
    ) -> ChatResponse:
        try:
            conversation_history = None
            if include_history:
                conversation_history = await self.session_service.get_conversation_history(session_id)

            response_message = await self.llm_service.generate_response(
                prompt=user_message,
                system_prompt=SYSTEM_PROMPT,
                conversation_history=conversation_history
            )

            await self.session_service.add_message(session_id, "assistant", response_message)

            return ChatResponse(
                session_id=session_id,
                message=response_message
            )

        except Exception as e:
            logger.error(f"Error in direct processing: {str(e)}", exc_info=True)
            raise

    async def _handle_order_inquiry(self, order_number: str) -> str:
        try:
            order_info = await self.order_service.get_order_status(order_number)

            if not order_info:
                return (
                    f"I couldn't find order {order_number} in our system. "
                    f"Please check the order number and try again, or contact support@example.com for assistance."
                )

            response = f"Here's the status of your order {order_info['order_number']}:\n\n"
            response += f"**Status:** {order_info['status']}\n"
            response += f"**Order Date:** {order_info['order_date']}\n"

            if order_info['status'] == "Delivered":
                response += f"**Delivered:** {order_info.get('delivered_date', 'N/A')}\n"
            else:
                response += f"**Estimated Delivery:** {order_info.get('estimated_delivery', 'N/A')}\n"

            response += f"**Items:** {', '.join(order_info['items'])}\n"
            response += f"**Total:** {order_info['total']}\n"

            if 'tracking_number' in order_info:
                response += f"\n**Tracking Number:** {order_info['tracking_number']}\n"
                response += f"**Carrier:** {order_info['carrier']}\n"

            response += "\nIs there anything else I can help you with?"
            return response

        except Exception as e:
            logger.error(f"Error handling order inquiry: {str(e)}")
            return "I'm having trouble retrieving order information right now. Please try again later or contact our support team."