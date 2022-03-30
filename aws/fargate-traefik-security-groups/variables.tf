variable "aws_vpc" {
  type = object({
    id = string
  })
}

variable "aws_security_group_traefik" {
  type = object({
    name = string
    tags = map(string)
  })
}

variable "aws_security_group_rule_traefik" {
  type = list(object({
    type        = string
    from_port   = string
    to_port     = string
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
}

variable "aws_security_group_traefik_apps" {
  type = object({
    name = string
    tags = map(string)
  })
}

variable "aws_security_group_rule_traefik_apps" {
  type = list(object({
    type        = string
    from_port   = string
    to_port     = string
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
}
