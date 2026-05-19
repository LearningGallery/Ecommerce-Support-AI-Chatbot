import logging
import uuid
from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any
import boto3
from config.settings import settings
from models.session_models import ChatSession, SessionMessage

logger = logging.getLogger(__name__)


class SessionService:
    """
    Service for managing chat sessions in DynamoDB.
    """

    def __init__(self):
        dynamodb = boto3.resource('dynamodb', region_name=settings.aws_region)
        self.table = dynamodb.Table(settings.dynamodb_table_name)
        self.ttl_hours = settings.session_ttl_hours

    async def create_session(
        self,
        user_id: str = "anonymous",
        metadata: Optional[Dict[str, Any]] = None
    ) -> str:
        try:
            session_id = str(uuid.uuid4())
            now = datetime.utcnow()
            ttl = int((now + timedelta(hours=self.ttl_hours)).timestamp())

            item = {
                'session_id': session_id,
                'user_id': user_id,
                'messages': [],
                'created_at': now.isoformat(),
                'updated_at': now.isoformat(),
                'ttl': ttl,
                'timestamp': int(now.timestamp())
            }

            if metadata:
                item['metadata'] = metadata

            self.table.put_item(Item=item)
            logger.info(f"Created session: {session_id}")
            return session_id

        except Exception as e:
            logger.error(f"Error creating session: {str(e)}", exc_info=True)
            raise

    async def get_session(self, session_id: str) -> Optional[ChatSession]:
        try:
            response = self.table.get_item(Key={'session_id': session_id, 'timestamp': 0})
            if 'Item' not in response:
                scan_response = self.table.scan(
                    FilterExpression='session_id = :sid',
                    ExpressionAttributeValues={':sid': session_id}
                )
                if not scan_response.get('Items'):
                    logger.warning(f"Session not found: {session_id}")
                    return None
                item = scan_response['Items'][0]
            else:
                item = response['Item']

            messages = [
                SessionMessage(
                    role=msg['role'],
                    content=msg['content'],
                    timestamp=datetime.fromisoformat(msg['timestamp'])
                )
                for msg in item.get('messages', [])
            ]

            return ChatSession(
                session_id=item['session_id'],
                user_id=item['user_id'],
                messages=messages,
                created_at=datetime.fromisoformat(item['created_at']),
                updated_at=datetime.fromisoformat(item['updated_at']),
                ttl=item['ttl'],
                metadata=item.get('metadata')
            )

        except Exception as e:
            logger.error(f"Error retrieving session: {str(e)}", exc_info=True)
            return None

    async def add_message(
        self,
        session_id: str,
        role: str,
        content: str
    ) -> bool:
        try:
            now = datetime.utcnow()

            scan_response = self.table.scan(
                FilterExpression='session_id = :sid',
                ExpressionAttributeValues={':sid': session_id}
            )

            if not scan_response.get('Items'):
                logger.warning(f"Session not found for add_message: {session_id}")
                return False

            item = scan_response['Items'][0]
            timestamp_key = item['timestamp']

            message = {
                'role': role,
                'content': content,
                'timestamp': now.isoformat()
            }

            self.table.update_item(
                Key={'session_id': session_id, 'timestamp': timestamp_key},
                UpdateExpression='SET messages = list_append(if_not_exists(messages, :empty_list), :message), updated_at = :updated_at',
                ExpressionAttributeValues={
                    ':message': [message],
                    ':updated_at': now.isoformat(),
                    ':empty_list': []
                }
            )

            logger.info(f"Added message to session: {session_id}")
            return True

        except Exception as e:
            logger.error(f"Error adding message to session: {str(e)}", exc_info=True)
            return False

    async def get_conversation_history(
        self,
        session_id: str,
        limit: int = 10
    ) -> List[Dict[str, str]]:
        try:
            session = await self.get_session(session_id)

            if not session:
                return []

            messages = session.messages[-limit:] if len(session.messages) > limit else session.messages

            return [
                {
                    'role': msg.role,
                    'content': msg.content
                }
                for msg in messages
            ]

        except Exception as e:
            logger.error(f"Error getting conversation history: {str(e)}", exc_info=True)
            return []

    async def delete_session(self, session_id: str) -> bool:
        try:
            scan_response = self.table.scan(
                FilterExpression='session_id = :sid',
                ExpressionAttributeValues={':sid': session_id}
            )

            if not scan_response.get('Items'):
                return False

            item = scan_response['Items'][0]
            self.table.delete_item(
                Key={
                    'session_id': session_id,
                    'timestamp': item['timestamp']
                }
            )
            logger.info(f"Deleted session: {session_id}")
            return True
        except Exception as e:
            logger.error(f"Error deleting session: {str(e)}", exc_info=True)
            return False