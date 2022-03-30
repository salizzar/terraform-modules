variable "aws_cloudwatch_event_rule" {
  type = list(object({
    name          = string
    description   = string
    event_pattern = string
  }))
}

variable "aws_cloudwatch_event_target" {
  type = list(object({
    target_id = string
    arn       = string
  }))
}
