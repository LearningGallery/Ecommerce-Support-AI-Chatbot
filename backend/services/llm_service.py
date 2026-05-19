import boto3
import json
import logging
from typing import List, Dict, Optional
from config.settings import settings

logger = logging.getLogger(__name__)


class BedrockLLMService:
    """
    Service for interacting with Amazon Bedrock LLM.
    """

    def __init__(self):
        self.client = boto3.client(
            service_name='bedrock-runtime',
            region_name=settings.aws_region
        )
        self.model_id = settings.bedrock_model_id
        self.max_tokens = settings.max_tokens
        self.temperature = settings.temperature

    async def generate_response(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        conversation_history: Optional[List[Dict[str, str]]] = None
    ) -> str:
        """
        Generate response from Bedrock LLM.
        """
        try:
            messages = []

            if conversation_history:
                for msg in conversation_history[-5:]:
                    messages.append({
                        "role": msg["role"],
                        "content": msg["content"]
                    })

            messages.append({
                "role": "user",
                "content": prompt
            })

            request_body = {
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": self.max_tokens,
                "temperature": self.temperature,
                "messages": messages
            }

            if system_prompt:
                request_body["system"] = system_prompt

            logger.info(f"Invoking Bedrock model: {self.model_id}")
            response = self.client.invoke_model(
                modelId=self.model_id,
                body=json.dumps(request_body)
            )

            response_body = json.loads(response['body'].read())

            if 'content' in response_body and len(response_body['content']) > 0:
                return response_body['content'][0]['text']

            logger.warning("No content in Bedrock response")
            return "I apologize, but I couldn't generate a response. Please try again."

        except Exception as e:
            logger.error(f"Error invoking Bedrock: {str(e)}", exc_info=True)
            raise Exception(f"Failed to generate LLM response: {str(e)}")

    def health_check(self) -> bool:
        try:
            boto3.client("bedrock", region_name=settings.aws_region).list_foundation_models()
            return True
        except Exception as e:
            logger.error(f"Bedrock health check failed: {str(e)}")
            return False