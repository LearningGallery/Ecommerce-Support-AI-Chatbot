import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from config.settings import settings
from api.routes import router
from services.retrieval_service import OpenSearchRetrievalService

logging.basicConfig(
    level=getattr(logging, settings.log_level.upper()),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting E-Commerce Chatbot API")
    logger.info(f"AWS Region: {settings.aws_region}")
    logger.info(f"Bedrock Model: {settings.bedrock_model_id}")

    try:
        retrieval_service = OpenSearchRetrievalService()
        await retrieval_service.ensure_index_exists()
        logger.info("OpenSearch initialization completed")
    except Exception as e:
        logger.error(f"Failed to initialize OpenSearch: {str(e)}")

    yield

    logger.info("Shutting down E-Commerce Chatbot API")


app = FastAPI(
    title="E-Commerce Customer Support Chatbot API",
    description="AI-powered customer support chatbot for e-commerce with RAG capabilities",
    version="1.0.0",
    lifespan=lifespan
)

allowed_origins = settings.allowed_cors_origins.split(",") if settings.allowed_cors_origins != "*" else ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    logger.error(f"Unhandled exception: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "An internal error occurred. Please try again later."}
    )


app.include_router(router, prefix="/api/v1", tags=["chat"])


@app.get("/")
async def root():
    return {
        "service": "E-Commerce Customer Support Chatbot API",
        "version": "1.0.0",
        "status": "operational",
        "docs": "/docs"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level=settings.log_level.lower()
    )