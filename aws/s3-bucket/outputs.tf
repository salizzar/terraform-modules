output "id" {
  value = aws_s3_bucket.bucket.id
}

output "bucket" {
  value = aws_s3_bucket.bucket.bucket
}

output "arn" {
  value = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.bucket.bucket_regional_domain_name
}

output "bucket_website_endpoint" {
  value = aws_s3_bucket.bucket.website_endpoint
}

output "bucket_website_domain" {
  value = aws_s3_bucket.bucket.website_domain
}

output "hosted_zone_id" {
  value = aws_s3_bucket.bucket.hosted_zone_id
}

output "region" {
  value = aws_s3_bucket.bucket.region
}

output "log_bucket" {
  value = aws_s3_bucket.log_bucket.*.bucket
}

output "log_bucket_arn" {
  value = aws_s3_bucket.bucket.*.arn
}
