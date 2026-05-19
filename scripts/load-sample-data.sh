#!/bin/bash

set -e

echo "=========================================="
echo "Loading Sample FAQ Data"
echo "=========================================="

cd terraform
SECRET_NAME=$(terraform output -raw secrets_manager_secret_name)
cd ..

export AWS_REGION="${AWS_REGION:-ap-southeast-1}"
export OPENSEARCH_INDEX_NAME="ecommerce-faq"

CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query SecretString --output text)
export OPENSEARCH_ENDPOINT=$(echo $CREDENTIALS | jq -r '.opensearch_endpoint')
export OPENSEARCH_USERNAME=$(echo $CREDENTIALS | jq -r '.opensearch_username')
export OPENSEARCH_PASSWORD=$(echo $CREDENTIALS | jq -r '.opensearch_password')

cd workers/ingestion
python main.py
cd ../..

echo ""
echo "=========================================="
echo "Sample data loaded successfully!"
echo "=========================================="