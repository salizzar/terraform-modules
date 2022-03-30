data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "kms-policy" {
  statement {
    sid = "Allows account root access"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["*"]

    resources = ["*"]
  }

  statement {
    sid = "Allow encryption for authorized users"

    principals {
      type        = "AWS"
      identifiers = "${var.aws_iam_policy_document["statement_allow_access_key_administrators"]}"
    }

    actions = [
      "kms:*",
    ]

    resources = [
      "arn:aws:s3:::${var.aws_s3_bucket["bucket"]}",
    ]
  }

  statement {
    sid = "Allow access to S3 bucket"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.aws_s3_bucket["bucket"]}",
    ]
  }

  statement {
    sid = "Allow access to S3 bucket files"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${var.aws_s3_bucket["bucket"]}/*",
    ]
  }

  statement {
    sid = "Allow use of the key"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      values   = ["s3.${data.aws_region.current.name}.amazonaws.com"]
      variable = "kms:ViaService"
    }

    condition {
      test     = "StringEquals"
      values   = ["${data.aws_caller_identity.current.account_id}"]
      variable = "kms:CallerAccount"
    }
  }
}
