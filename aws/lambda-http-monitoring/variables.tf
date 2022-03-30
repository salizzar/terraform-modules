variable "aws_kms_key" {
  type = object({
    description             = string
    deletion_window_in_days = number
    tags                    = map(string)
  })
}

variable "aws_kms_alias" {
  type = object({
    name = string
  })
}

variable "aws_iam_role" {
  type = object({
    name = string
  })
}

variable "aws_iam_role_policy" {
  type = object({
    name = string
  })
}

variable "aws_lambda_function" {
  type = object({
    watchtower = object({
      function_name = string
      runtime       = string
      tags          = map(string)

      environment = object({
        variables = map(string)
      })
    })

    alerts = object({
      function_name = string
      runtime       = string
      tags          = map(string)

      environment = object({
        variables = map(string)
      })
    })
  })
}

variable "aws_cloudwatch_event_rule" {
  type = object({
    name                = string
    description         = string
    schedule_expression = string
    tags                = map(string)
  })
}

variable "aws_cloudwatch_event_target" {
  type = object({
    target_id = string
    input     = string
  })
}

variable "aws_sns_topic" {
  type = object({
    name = string
    tags = map(string)
  })
}
