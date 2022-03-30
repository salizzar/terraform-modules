variable "aws_vpc" {
  type = object({
    id = string
  })
}

variable "aws_lb" {
  type = object({
    name                       = string
    internal                   = bool
    enable_deletion_protection = bool
    subnets                    = list(string)
    tags                       = map(string)
  })
}

variable "aws_lb_target_group" {
  type = object({
    name        = string
    port        = number
    protocol    = string
    target_type = string

    health_check = object({
      protocol            = string
      interval            = number
      port                = number
      path                = string
      healthy_threshold   = number
      unhealthy_threshold = number
      timeout             = number
      matcher             = string
    })
  })
}

variable "aws_lb_listener" {
  type = object({
    http_enabled    = bool
    https_enabled   = bool
    certificate_arn = string
  })
}

variable "aws_security_group" {
  type = object({
    name = string
    tags = map(string)
  })
}

variable "aws_security_group_rules" {
  type = list(object({
    type        = string
    from_port   = string
    to_port     = string
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
}

variable "aws_route53_record" {
  type = object({
    create  = bool
    name    = string
    zone_id = string
  })
}
