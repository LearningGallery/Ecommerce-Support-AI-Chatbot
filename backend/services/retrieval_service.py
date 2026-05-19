import logging
from typing import List, Dict, Any, Optional
from opensearchpy import OpenSearch, RequestsHttpConnection
from config.settings import settings

logger = logging.getLogger(__name__)


class OpenSearchRetrievalService:
    """
    Service for retrieving relevant documents from OpenSearch.
    """

    def __init__(self):
        self.client = OpenSearch(
            hosts=[{'host': settings.opensearch_endpoint.replace('https://', ''), 'port': 443}],
            http_auth=(settings.opensearch_username, settings.opensearch_password),
            use_ssl=True,
            verify_certs=True,
            connection_class=RequestsHttpConnection,
            timeout=settings.opensearch_timeout
        )
        self.index_name = settings.opensearch_index_name

    async def search(
        self,
        query: str,
        top_k: int = None,
        filters: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        try:
            top_k = top_k or settings.retrieval_top_k

            search_body = {
                "size": top_k,
                "query": {
                    "multi_match": {
                        "query": query,
                        "fields": ["content^2", "title", "category"],
                        "type": "best_fields",
                        "minimum_should_match": "75%"
                    }
                },
                "_source": ["content", "title", "category", "metadata"]
            }

            if filters:
                search_body["query"] = {
                    "bool": {
                        "must": [search_body["query"]],
                        "filter": [{"term": {k: v}} for k, v in filters.items()]
                    }
                }

            logger.info(f"Searching OpenSearch index: {self.index_name}")
            response = self.client.search(
                index=self.index_name,
                body=search_body
            )

            results = []
            for hit in response['hits']['hits']:
                if hit['_score'] >= settings.min_relevance_score:
                    results.append({
                        'content': hit['_source'].get('content', ''),
                        'title': hit['_source'].get('title', ''),
                        'category': hit['_source'].get('category', ''),
                        'score': hit['_score'],
                        'metadata': hit['_source'].get('metadata', {})
                    })

            logger.info(f"Found {len(results)} relevant documents")
            return results

        except Exception as e:
            logger.error(f"Error searching OpenSearch: {str(e)}", exc_info=True)
            return []

    def health_check(self) -> bool:
        try:
            self.client.info()
            return True
        except Exception as e:
            logger.error(f"OpenSearch health check failed: {str(e)}")
            return False

    async def ensure_index_exists(self):
        try:
            if not self.client.indices.exists(index=self.index_name):
                logger.info(f"Creating index: {self.index_name}")

                index_body = {
                    "settings": {
                        "number_of_shards": 1,
                        "number_of_replicas": 1
                    },
                    "mappings": {
                        "properties": {
                            "content": {"type": "text"},
                            "title": {"type": "text"},
                            "category": {"type": "keyword"},
                            "metadata": {"type": "object"}
                        }
                    }
                }

                self.client.indices.create(index=self.index_name, body=index_body)
                logger.info(f"Index created: {self.index_name}")
        except Exception as e:
            logger.error(f"Error ensuring index exists: {str(e)}")