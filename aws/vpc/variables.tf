variable "aws_vpc" {
  type = object({
    name                 = string
    cidr_block           = string
    enable_dns_support   = bool
    enable_dns_hostnames = bool
    tags                 = map(string)
  })
}

variable "aws_nat_gateway" {
  type = object({
    count = number
  })
}

variable "aws_subnet" {
  type = object({
    pub = object({
      availability_zones = list(string)

      dmz           = object({ cidr_blocks = list(string) })
      alb           = object({ cidr_blocks = list(string) })
      docker        = object({ cidr_blocks = list(string) })
      ec2           = object({ cidr_blocks = list(string) })
      ecs           = object({ cidr_blocks = list(string) })
      elasticache   = object({ cidr_blocks = list(string) })
      elasticsearch = object({ cidr_blocks = list(string) })
      lambda        = object({ cidr_blocks = list(string) })
      rds           = object({ cidr_blocks = list(string) })
    })

    prv = object({
      availability_zones = list(string)

      alb           = object({ cidr_blocks = list(string) })
      docker        = object({ cidr_blocks = list(string) })
      ec2           = object({ cidr_blocks = list(string) })
      ecs           = object({ cidr_blocks = list(string) })
      elasticache   = object({ cidr_blocks = list(string) })
      elasticsearch = object({ cidr_blocks = list(string) })
      lambda        = object({ cidr_blocks = list(string) })
      rds           = object({ cidr_blocks = list(string) })
    })
  })

  default = {
    pub = {
      availability_zones = []

      dmz           = { cidr_blocks = [] }
      alb           = { cidr_blocks = [] }
      docker        = { cidr_blocks = [] }
      ec2           = { cidr_blocks = [] }
      ecs           = { cidr_blocks = [] }
      elasticache   = { cidr_blocks = [] }
      elasticsearch = { cidr_blocks = [] }
      lambda        = { cidr_blocks = [] }
      rds           = { cidr_blocks = [] }
    }

    prv = {
      availability_zones = []

      alb           = { cidr_blocks = [] }
      docker        = { cidr_blocks = [] }
      ec2           = { cidr_blocks = [] }
      ecs           = { cidr_blocks = [] }
      elasticache   = { cidr_blocks = [] }
      elasticsearch = { cidr_blocks = [] }
      lambda        = { cidr_blocks = [] }
      rds           = { cidr_blocks = [] }
    }
  }
}
