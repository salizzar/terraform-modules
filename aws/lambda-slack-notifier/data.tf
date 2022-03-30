data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "kms" {
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
    sid = "Allow access to Lambda"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "lambda:*",
    ]

    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.aws_lambda_function["function_name"]}",
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
      values   = ["lambda.${data.aws_region.current.name}.amazonaws.com"]
      variable = "kms:ViaService"
    }

    condition {
      test     = "StringEquals"
      values   = ["${data.aws_caller_identity.current.account_id}"]
      variable = "kms:CallerAccount"
    }
  }
}

data "aws_iam_policy_document" "sns" {
  statement {
    sid    = "default"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
    ]

    resources = [
      "${aws_sns_topic.main.arn}",
    ]

    condition {
      test     = "StringEquals"
      values   = ["${data.aws_caller_identity.current.account_id}"]
      variable = "AWS:SourceOwner"
    }
  }

  statement {
    sid     = "allow-cloudwatch-events"
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.main.arn}"]
  }
}
