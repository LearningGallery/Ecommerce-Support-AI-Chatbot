from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # AWS Configuration
    aws_region: str = "ap-southeast-1"

    # Bedrock Configuration
    bedrock_model_id: str = "anthropic.claude-3-5-sonnet-20241022-v2:0"
    max_tokens: int = 1024
    temperature: float = 0.7

    # OpenSearch Configuration
    opensearch_endpoint: str
    opensearch_username: str
    opensearch_password: str
    opensearch_index_name: str = "ecommerce-faq"
    opensearch_timeout: int = 30

    # DynamoDB Configuration
    dynamodb_table_name: str

    # S3 Configuration
    s3_documents_bucket: str

    # Application Configuration
    log_level: str = "INFO"
    allowed_cors_origins: str = "*"
    session_ttl_hours: int = 24

    # RAG Configuration
    retrieval_top_k: int = 5
    min_relevance_score: float = 0.7
    chunk_size: int = 512
    chunk_overlap: int = 50

    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()