locals {
  additional_tags = {
    Environment = terraform.workspace
    CreatedBy   = "terraform"
  }
}

resource "aws_kms_key" "kms-key" {
  count = var.aws_kms_key.enabled ? 1 : 0

  description             = var.aws_kms_key.description
  policy                  = data.aws_iam_policy_document.kms-policy.json
  deletion_window_in_days = var.aws_kms_key.deletion_window_in_days
  tags                    = merge(var.aws_kms_key.tags, local.additional_tags)
}

resource "aws_kms_alias" "alias" {
  count = var.aws_kms_key.enabled ? 1 : 0

  name          = "alias/${var.aws_kms_alias.name}"
  target_key_id = aws_kms_key.kms-key[0].key_id
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.aws_s3_bucket.bucket
  acl    = var.aws_s3_bucket.acl

  versioning {
    enabled = var.aws_s3_bucket.versioning.enabled
  }

  dynamic "website" {
    for_each = var.aws_s3_bucket.website != null ? [1] : []

    content {
      index_document           = var.aws_s3_bucket.website.index_document
      error_document           = var.aws_s3_bucket.website.error_document
      redirect_all_requests_to = var.aws_s3_bucket.website.redirect_all_requests_to
      routing_rules            = var.aws_s3_bucket.website.routing_rules
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.aws_kms_key.enabled ? [1] : []

    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = aws_kms_key.kms-key[0].arn
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }

  tags = merge(var.aws_s3_bucket.tags, local.additional_tags)
}

resource "aws_s3_bucket_policy" "policy" {
  count = var.aws_s3_bucket_policy.enabled ? 1 : 0

  bucket = aws_s3_bucket.bucket.bucket
  policy = var.aws_s3_bucket_policy.policy
}

resource "aws_s3_bucket_public_access_block" "access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.aws_s3_bucket_public_access_block.block_public_acls
  block_public_policy     = var.aws_s3_bucket_public_access_block.block_public_policy
  ignore_public_acls      = var.aws_s3_bucket_public_access_block.ignore_public_acls
  restrict_public_buckets = var.aws_s3_bucket_public_access_block.restrict_public_buckets
}

resource "aws_dynamodb_table" "dynamodb-lock" {
  count = var.aws_dynamodb_table.enabled ? 1 : 0

  name = var.aws_dynamodb_table.name

  hash_key       = "LockID"
  read_capacity  = var.aws_dynamodb_table.read_capacity
  write_capacity = var.aws_dynamodb_table.write_capacity

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.aws_dynamodb_table.tags, local.additional_tags)
}
