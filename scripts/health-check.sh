#!/bin/bash

set -e

cd terraform
BACKEND_URL=$(terraform output -raw backend_alb_dns)
APP_URL=$(terraform output -raw application_url)
cd ..

echo "=========================================="
echo "Health Check"
echo "=========================================="

echo ""
echo "Checking backend API health..."
BACKEND_HEALTH=$(curl -s "http://$BACKEND_URL/api/v1/health")
echo "Backend: $BACKEND_HEALTH"

BACKEND_STATUS=$(echo $BACKEND_HEALTH | jq -r '.status')
if [ "$BACKEND_STATUS" != "healthy" ] && [ "$BACKEND_STATUS" != "degraded" ]; then
    echo "❌ Backend health check failed!"
    exit 1
fi
echo "✅ Backend is $BACKEND_STATUS"

echo ""
echo "Checking CloudFront distribution..."
CF_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL")
if [ "$CF_RESPONSE" != "200" ]; then
    echo "⚠️ CloudFront returned status: $CF_RESPONSE"
else
    echo "✅ CloudFront is accessible"
fi

echo ""
echo "Checking service status..."
BEDROCK_STATUS=$(echo $BACKEND_HEALTH | jq -r '.services.bedrock')
OPENSEARCH_STATUS=$(echo $BACKEND_HEALTH | jq -r '.services.opensearch')
DYNAMODB_STATUS=$(echo $BACKEND_HEALTH | jq -r '.services.dynamodb')

echo "  Bedrock:    $BEDROCK_STATUS"
echo "  OpenSearch: $OPENSEARCH_STATUS"
echo "  DynamoDB:   $DYNAMODB_STATUS"

echo ""
echo "=========================================="
echo "Health check completed!"
echo "Application URL: $APP_URL"
echo "=========================================="