variable "cloudwatch_dashboards" {
  type = object({
    payload = string
  })
}

variable "aws_cloudformation_stack" {
  type = object({
    name = string
  })
}
