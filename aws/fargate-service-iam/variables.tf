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
