variable "aws_kms_key" {
  type = object({
    description             = string
    deletion_window_in_days = number

    tags = map(string)
  })
}

variable "aws_kms_alias" {
  type = object({
    name = string
  })
}

variable "aws_sns_topic" {
  type = object({
    name = string
    tags = map(string)
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
    function_name = string
    runtime       = string

    environment = object({
      variables = map(string)
    })

    tags = map(string)
  })
}
