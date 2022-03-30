variable "aws_iam_user" {
  type = object({
    name = string
    path = string
    tags = map(string)
  })
}

variable "aws_iam_access_key" {
  type = object({
    pgp_key = string
  })
}

variable "aws_iam_role" {
  type = object({
    name = string
    tags = map(string)
  })
}

variable "aws_iam_role_policy" {
  type = object({
    name = string
  })
}

variable "aws_iam_user_policy" {
  type = object({
    name = string
  })
}
