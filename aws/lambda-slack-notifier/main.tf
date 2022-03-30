locals {
  additional_tags = {
    Environment = terraform.workspace
  }
}

#
# KMS
#

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

#
# SNS topic
#

resource "aws_sns_topic" "main" {
  name = var.aws_sns_topic.name
  tags = merge(var.aws_sns_topic.tags, local.additional_tags)
}

resource "aws_sns_topic_subscription" "main" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.main.arn
}

resource "aws_sns_topic_policy" "main" {
  arn    = aws_sns_topic.main.arn
  policy = data.aws_iam_policy_document.sns.json
}

#
# Lambda
#

resource "aws_iam_role" "lambda" {
  name = var.aws_iam_role.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
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
                "logs:PutLogEvents"
            ],
            "Resource": [
								"*"
						]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": [
								"${aws_kms_key.kms.arn}"
            ]
        }
    ]
}
EOF
}

data "external" "npm" {
  program = ["bash", "${path.module}/lambda/build.sh"]
}

data "archive_file" "lambda" {
  depends_on = [data.external.npm]

  type        = "zip"
  source_dir  = "${path.module}/lambda/src"
  output_path = "${path.module}/lambda/out/lambda_function.zip"
}

resource "aws_lambda_function" "main" {
  depends_on = [aws_sns_topic.main]

  function_name    = var.aws_lambda_function.function_name
  filename         = "${path.module}/lambda/out/lambda_function.zip"
  role             = aws_iam_role.lambda.arn
  source_code_hash = data.archive_file.lambda.output_base64sha256
  kms_key_arn      = aws_kms_key.kms.arn
  runtime          = var.aws_lambda_function.runtime
  handler          = "index.handler"
  publish          = true

  environment {
    variables = var.aws_lambda_function.environment.variables
  }

  tags = merge(var.aws_lambda_function.tags, local.additional_tags)
}

resource "aws_lambda_permission" "sns" {
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.main.arn
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
}
