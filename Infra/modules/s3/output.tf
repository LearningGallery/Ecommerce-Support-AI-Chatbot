output "documents_bucket_name" {
  description = "Documents bucket name"
  value       = aws_s3_bucket.documents.id
}

output "documents_bucket_arn" {
  description = "Documents bucket ARN"
  value       = aws_s3_bucket.documents.arn
}

output "static_bucket_name" {
  description = "Static assets bucket name"
  value       = aws_s3_bucket.static.id
}

output "static_bucket_arn" {
  description = "Static assets bucket ARN"
  value       = aws_s3_bucket.static.arn
}