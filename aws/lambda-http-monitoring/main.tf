locals {
  additional_tags = {
    Environment = terraform.workspace
  }
}

resource "aws_kms_key" "kms" {
  description             = var.aws_kms_key.description
  deletion_window_in_days = var.aws_kms_key.deletion_window_in_days
  policy                  = data.aws_iam_policy_document.kms.json
  tags                    = merge(var.aws_kms_key.tags, local.additional_tags)
}

resource "aws_kms_alias" "alias" {
  name          = var.aws_kms_alias.name
  target_key_id = aws_kms_key.kms.key_id
}

resource "aws_iam_role" "lambda" {
  name = var.aws_iam_role.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda" {
  name = var.aws_iam_role_policy.name
  role = aws_iam_role.lambda.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "cloudwatch:PutMetricData"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}

data "external" "git_clone" {
  program = ["bash", "${path.module}/bin/setup"]

  query = {
    source_path = "${path.module}/lambdas/watchtower/src"
    git_repo    = "https://github.com/wmnnd/lambda-watchtower.git"
  }
}

module "lambda-builder-watchtower" {
  source = "../lambda-builder"

  lambda = {
    source_path = data.external.git_clone.result["lambda_src"]
    output_path = "${path.module}/lambdas/watchtower/out/watchtower.zip"
  }
}

resource "aws_lambda_function" "watchtower" {
  depends_on = [data.external.git_clone, module.lambda-builder-watchtower]

  function_name    = var.aws_lambda_function.watchtower.function_name
  filename         = "${path.module}/lambdas/watchtower/out/watchtower.zip"
  role             = aws_iam_role.lambda.arn
  source_code_hash = module.lambda-builder-watchtower.output_base64sha256
  kms_key_arn      = aws_kms_key.kms.arn
  runtime          = var.aws_lambda_function.watchtower.runtime
  handler          = "index.handler"
  publish          = true

  dynamic "environment" {
    for_each = var.aws_lambda_function.watchtower.environment != null ? [1] : []

    content {
      variables = var.aws_lambda_function.watchtower.environment.variables
    }
  }

  tags = merge(var.aws_lambda_function.watchtower.tags, local.additional_tags)
}

resource "aws_lambda_permission" "watchtower" {
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.watchtower.arn
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.watchtower.function_name
}

resource "aws_cloudwatch_event_rule" "watchtower" {
  name                = var.aws_cloudwatch_event_rule.name
  description         = var.aws_cloudwatch_event_rule.description
  schedule_expression = var.aws_cloudwatch_event_rule.schedule_expression
  tags                = merge(var.aws_cloudwatch_event_rule.tags, local.additional_tags)
}

resource "aws_cloudwatch_event_target" "watchtower" {
  rule      = aws_cloudwatch_event_rule.watchtower.name
  target_id = var.aws_cloudwatch_event_target.target_id
  arn       = aws_lambda_function.watchtower.arn
  input     = var.aws_cloudwatch_event_target.input
}

resource "aws_sns_topic" "alerts" {
  name = var.aws_sns_topic.name
  tags = merge(var.aws_sns_topic.tags, local.additional_tags)
}

resource "aws_sns_topic_subscription" "alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alerts.arn
}

resource "aws_sns_topic_policy" "alerts" {
  arn    = aws_sns_topic.alerts.arn
  policy = data.aws_iam_policy_document.alerts.json
}

module "lambda-builder-alerts" {
  source = "../lambda-builder"

  lambda = {
    source_path = "${path.module}/lambdas/alerts/src"
    output_path = "${path.module}/lambdas/alerts/out/alerts.zip"
  }
}

resource "aws_lambda_function" "alerts" {
  depends_on = [module.lambda-builder-alerts]

  function_name    = var.aws_lambda_function.alerts.function_name
  filename         = "${path.module}/lambdas/alerts/out/alerts.zip"
  role             = aws_iam_role.lambda.arn
  source_code_hash = module.lambda-builder-alerts.output_base64sha256
  kms_key_arn      = aws_kms_key.kms.arn
  runtime          = var.aws_lambda_function.alerts.runtime
  handler          = "index.handler"
  publish          = true

  environment {
    variables = var.aws_lambda_function.alerts.environment.variables
  }

  tags = merge(var.aws_lambda_function.alerts.tags, local.additional_tags)
}

resource "aws_lambda_permission" "alerts" {
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alerts.function_name
}
