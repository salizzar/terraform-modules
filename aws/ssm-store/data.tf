data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "kms-policy" {
  statement {
    sid = "Allows account root access"

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }

    actions = ["*"]

    resources = ["*"]
  }

  statement {
    sid = "Allow access to SSM"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "ssm:*",
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${local.application_path}/*",
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
      values   = ["ssm.${data.aws_region.current.name}.amazonaws.com"]
      variable = "kms:ViaService"
    }

    condition {
      test     = "StringEquals"
      values   = ["${data.aws_caller_identity.current.account_id}"]
      variable = "kms:CallerAccount"
    }
  }
}
