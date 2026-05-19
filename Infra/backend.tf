# Uncomment after creating S3 bucket and DynamoDB table for state management
# 
# To create backend resources:
# aws s3 mb s3://ecommerce-chatbot-tfstate --region ap-southeast-1
# aws dynamodb create-table \
#   --table-name ecommerce-chatbot-tfstate-lock \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST \
#   --region ap-southeast-1

# terraform {
#   backend "s3" {
#     bucket         = "ecommerce-chatbot-tfstate"
#     key            = "chatbot/terraform.tfstate"
#     region         = "ap-southeast-1"
#     encrypt        = true
#     dynamodb_table = "ecommerce-chatbot-tfstate-lock"
#   }
# }