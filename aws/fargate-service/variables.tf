variable "aws_ecs_cluster" {
  type = object({
    id   = string
    name = string
  })
}

variable "aws_cloudwatch_log_group" {
  type = object({
    name = string
    tags = map(string)
  })
}

variable "aws_ecs_task_definition" {
  type = object({
    family                = string
    cpu                   = number
    memory                = number
    container_definitions = string
    execution_role_arn    = string
  })
}

variable "aws_ecs_service" {
  type = object({
    exposed_to_load_balancer = bool
    name                     = string
    desired_count            = number

    load_balancer = object({
      target_group_arn = string
      container_name   = string
      container_port   = number
    })

    network_configuration = object({
      subnets         = list(string)
      security_groups = list(string)
    })
  })

  default = {
    exposed_to_load_balancer = false
    name                     = ""
    desired_count            = 0

    load_balancer = null

    network_configuration = {
      subnets         = []
      security_groups = []
    }
  }
}

variable "aws_appautoscaling_target" {
  type = object({
    scalable_dimension = string
    min_capacity       = number
    max_capacity       = number
  })

  default = {
    enabled            = false
    scalable_dimension = ""
    min_capacity       = 0
    max_capacity       = 0
  }
}

variable "aws_appautoscaling_policy" {
  type = list(object({
    name                        = string
    scalable_dimension          = string
    adjustment_type             = string
    cooldown                    = number
    metric_aggregation_type     = string
    metric_interval_lower_bound = string
    metric_interval_upper_bound = string
    scaling_adjustment          = number
  }))
}
