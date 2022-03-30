variable "aws_vpc" {
  type = "map"

  default = {
    tags_name = ""
  }
}

variable "aws_subnet_ids_mgr" {
  type = "map"

  default = {
    tags_kind = ""
    tags_type = ""
  }
}

variable "aws_subnet_ids_wkr" {
  type = "map"

  default = {
    tags_kind = ""
    tags_type = ""
  }
}

variable "aws_security_group" {
  type = "map"

  default = {
    name      = ""
    tags_name = ""
  }
}

variable "aws_instance_mgr" {
  type = "map"

  default = {
    count                  = 0
    instance_type          = ""
    key_name               = ""
    ami                    = ""
    ebs_optimized          = false
    vpc_security_group_ids = ""

    root_block_device_volume_type           = ""
    root_block_device_volume_size           = 0
    root_block_device_delete_on_termination = true

    tags_name = ""
  }
}

variable "aws_instance_wkr" {
  type = "map"

  default = {
    count                  = 0
    instance_type          = ""
    key_name               = ""
    ami                    = ""
    ebs_optimized          = false
    vpc_security_group_ids = ""

    root_block_device_volume_type           = ""
    root_block_device_volume_size           = 0
    root_block_device_delete_on_termination = true

    tags_name = ""
  }
}
