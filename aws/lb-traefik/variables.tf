variable "aws_vpc" {
  type = object({
    id = string
  })
}

variable "aws_lb" {
  type = object({
    arn = string
  })
}

variable "aws_lb_target_group" {
  type = object({
    name        = string
    port        = number
    protocol    = string
    target_type = string
    tags        = map(string)

    health_check = object({
      protocol            = string
      interval            = number
      path                = string
      healthy_threshold   = number
      unhealthy_threshold = number
      timeout             = number
      matcher             = string
    })
  })
}

variable "aws_security_group_rule" {
  type = object({
    security_group_id = string

    inbound = list(object({
      description = string
      cidr_blocks = list(string)
    }))

    outbound = list(object({
      description = string
      cidr_blocks = list(string)
    }))
  })
}
