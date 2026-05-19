import logging
from typing import List, Dict, Any
from opensearchpy import OpenSearch, RequestsHttpConnection
from chunker import TextChunker
import os

logger = logging.getLogger(__name__)


class FAQIngester:
    """
    Service for ingesting FAQ documents into OpenSearch.
    """

    def __init__(self):
        opensearch_endpoint = os.getenv('OPENSEARCH_ENDPOINT', '').replace('https://', '')
        opensearch_username = os.getenv('OPENSEARCH_USERNAME', 'admin')
        opensearch_password = os.getenv('OPENSEARCH_PASSWORD')
        index_name = os.getenv('OPENSEARCH_INDEX_NAME', 'ecommerce-faq')

        self.client = OpenSearch(
            hosts=[{'host': opensearch_endpoint, 'port': 443}],
            http_auth=(opensearch_username, opensearch_password),
            use_ssl=True,
            verify_certs=True,
            connection_class=RequestsHttpConnection,
            timeout=30
        )

        self.index_name = index_name
        self.chunker = TextChunker()

    def ingest_documents(self, documents: List[Dict[str, Any]]) -> int:
        success_count = 0

        for doc in documents:
            try:
                chunks = self.chunker.chunk_document(
                    text=doc.get('content', ''),
                    metadata={
                        'title': doc.get('title', ''),
                        'category': doc.get('category', ''),
                        'source': doc.get('source', 'faq')
                    }
                )

                for i, chunk in enumerate(chunks):
                    doc_id = f"{doc.get('id', 'unknown')}_{i}"

                    index_doc = {
                        'content': chunk['content'],
                        'title': doc.get('title', ''),
                        'category': doc.get('category', ''),
                        'metadata': {
                            **chunk['metadata'],
                            'chunk_index': i,
                            'total_chunks': len(chunks)
                        }
                    }

                    self.client.index(
                        index=self.index_name,
                        id=doc_id,
                        body=index_doc,
                        refresh=True
                    )

                success_count += 1
                logger.info(f"Ingested document: {doc.get('title', 'unknown')} ({len(chunks)} chunks)")

            except Exception as e:
                logger.error(f"Failed to ingest document {doc.get('id', 'unknown')}: {str(e)}")

        return success_count