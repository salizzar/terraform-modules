variable "aws_vpc" {
  type = "map"

  default = {
    tags_name = ""
  }
}

variable "aws_alb_target_group" {
  type = "map"

  default = {
    arn = ""
  }
}

variable "aws_key_pair" {
  type = "map"

  default = {
    key_name   = ""
    public_key = ""
  }
}

variable "aws_launch_configuration" {
  type = "map"

  default = {
    name_prefix     = ""
    image_id        = ""
    instance_type   = ""
    security_groups = ""
    key_name        = ""
  }
}

variable "aws_autoscaling_group" {
  type = "map"

  default = {
    name             = ""
    min_size         = 0
    max_size         = 0
    desired_capacity = 0

    vpc_zone_identifier = ""

    tag_name    = ""
    tag_release = ""
  }
}

variable "aws_autoscaling_policy_scale-up" {
  type = "map"

  default = {
    name               = ""
    scaling_adjustment = 0
    cooldown           = 0
  }
}

variable "aws_autoscaling_policy_scale-down" {
  type = "map"

  default = {
    name               = ""
    scaling_adjustment = 0
    cooldown           = 0
  }
}

variable "aws_cloudwatch_metric_alarm_cpu-up" {
  type = "map"

  default = {
    count = 0

    alarm_name         = ""
    alarm_description  = ""
    evaluation_periods = 0
    period             = 0
    threshold          = 0
  }
}

variable "aws_cloudwatch_metric_alarm_cpu-down" {
  type = "map"

  default = {
    count = 0

    alarm_name         = ""
    alarm_description  = ""
    evaluation_periods = 0
    period             = 0
    threshold          = 0
  }
}

variable "aws_cloudwatch_metric_alarm_ram-up" {
  type = "map"

  default = {
    count = 0

    alarm_name         = ""
    alarm_description  = ""
    evaluation_periods = 0
    period             = 0
    threshold          = 0
  }
}

variable "aws_cloudwatch_metric_alarm_ram-down" {
  type = "map"

  default = {
    count = 0

    alarm_name         = ""
    alarm_description  = ""
    evaluation_periods = 0
    period             = 0
    threshold          = 0
  }
}
