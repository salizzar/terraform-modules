output "id" {
  value = aws_s3_bucket.bucket.id
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

output "hosted_zone_id" {
  value = aws_s3_bucket.bucket.hosted_zone_id
}

output "region" {
  value = aws_s3_bucket.bucket.region
}
