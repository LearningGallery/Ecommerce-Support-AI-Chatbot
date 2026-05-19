from unittest.mock import MagicMock
import pytest
from services.retrieval_service import OpenSearchRetrievalService


@pytest.mark.asyncio
async def test_search_returns_results(monkeypatch):
    service = OpenSearchRetrievalService()

    mock_response = {
        "hits": {
            "hits": [
                {
                    "_score": 1.2,
                    "_source": {
                        "content": "Shipping takes 5-7 business days.",
                        "title": "Shipping Policy",
                        "category": "Shipping",
                        "metadata": {}
                    }
                }
            ]
        }
    }

    service.client = MagicMock()
    service.client.search.return_value = mock_response

    results = await service.search("shipping policy")
    assert len(results) == 1
    assert results[0]["title"] == "Shipping Policy"