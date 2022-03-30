variable "aws_vpc" {
  type = "map"

  default = {
    tags_name = ""
  }
}

variable "aws_subnet_ids_rds" {
  type = "map"

  default = {
    tags_kind = ""
    tags_type = ""
  }
}

variable "aws_security_group" {
  type = "map"

  default = {
    tags_name = ""
  }
}

variable "aws_security_group_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
  }))
}

variable "aws_db_subnet_group" {
  type = "map"

  default = {
    name = ""

    tags_name = ""
  }
}

variable "aws_db_instance" {
  type = "map"

  default = {
    allocated_storage       = 0
    backup_retention_period = 0
    monitoring_interval     = 0
    backup_window           = ""
    maintenance_window      = ""
    identifier              = ""
    storage_type            = ""
    engine                  = ""
    engine_version          = ""
    instance_class          = ""
    name                    = ""
    username                = ""
    password                = ""
    parameter_group_name    = ""
    multi_az                = false
    publicly_accessible     = false
  }
}
