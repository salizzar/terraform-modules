variable "aws_vpc" {
  type = "map"

  default = {
    id = ""
  }
}

variable "aws_security_group_internal" {
  type = "map"

  default = {
    name      = ""
    tags_name = ""
  }
}

variable "aws_security_group_bastion" {
  type = "map"

  default = {
    name      = ""
    tags_name = ""
  }
}

variable "aws_security_group_rule_ingress_ssh_bastion" {
  type = list(object({
    description = string
    cidr_blocks = list(string)
  }))
}

variable "aws_key_pair" {
  type = "map"

  default = {
    key_name   = ""
    public_key = ""
  }
}

variable "aws_subnet" {
  type = "map"

  default = {
    id = ""
  }
}

variable "aws_instance" {
  type = "map"

  default = {
    instance_type = ""
    ami           = ""
    key_name      = ""
    tags_name     = ""
  }
}

variable "aws_route53_record" {
  type = "map"

  default = {
    zone = ""
    name = ""
    type = ""
    ttl  = 60
  }
}
