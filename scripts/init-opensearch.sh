#!/bin/bash

set -e

cd terraform
OPENSEARCH_ENDPOINT=$(terraform output -raw opensearch_endpoint)
SECRET_NAME=$(terraform output -raw secrets_manager_secret_name)
cd ..

CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query SecretString --output text)
OPENSEARCH_USERNAME=$(echo $CREDENTIALS | jq -r '.opensearch_username')
OPENSEARCH_PASSWORD=$(echo $CREDENTIALS | jq -r '.opensearch_password')

echo "=========================================="
echo "Initializing OpenSearch Index"
echo "=========================================="
echo "Endpoint: $OPENSEARCH_ENDPOINT"
echo "=========================================="

curl -X PUT "https://$OPENSEARCH_ENDPOINT/ecommerce-faq" \
  -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
  -H 'Content-Type: application/json' \
  -d '{
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 1
    },
    "mappings": {
      "properties": {
        "content": { "type": "text" },
        "title": { "type": "text" },
        "category": { "type": "keyword" },
        "metadata": { "type": "object" }
      }
    }
  }' || true

echo ""
echo "=========================================="
echo "OpenSearch index initialized."
echo "=========================================="