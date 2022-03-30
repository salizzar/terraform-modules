locals {
  service_is_exposed    = var.aws_ecs_service.exposed_to_load_balancer
  create_appautoscaling = var.aws_appautoscaling_target != null
  service_name          = var.aws_ecs_service.name
  cluster_id            = var.aws_ecs_cluster.id
  cluster_name          = var.aws_ecs_cluster.name

  additional_tags = {
    Application = local.service_name
    Environment = terraform.workspace
  }
}

#
# CloudWatch logs
#

resource "aws_cloudwatch_log_group" "main" {
  name = var.aws_cloudwatch_log_group.name

  tags = merge(var.aws_cloudwatch_log_group.tags, local.additional_tags)
}

#
# ECS
#

resource "aws_ecs_task_definition" "main" {
  family                   = var.aws_ecs_task_definition.family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.aws_ecs_task_definition.cpu
  memory                   = var.aws_ecs_task_definition.memory

  container_definitions = var.aws_ecs_task_definition.container_definitions
  execution_role_arn    = var.aws_ecs_task_definition.execution_role_arn
}

resource "aws_ecs_service" "main" {
  name            = var.aws_ecs_service.name
  cluster         = local.cluster_id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.aws_ecs_service.desired_count

  lifecycle {
    ignore_changes = [desired_count]
  }

  dynamic "load_balancer" {
    for_each = local.service_is_exposed ? [1] : []

    content {
      target_group_arn = data.aws_lb_target_group.tg[0].arn
      container_name   = var.aws_ecs_service.load_balancer.container_name
      container_port   = var.aws_ecs_service.load_balancer.container_port
    }
  }

  network_configuration {
    subnets         = var.aws_ecs_service.network_configuration.subnets
    security_groups = var.aws_ecs_service.network_configuration.security_groups
  }
}

#
# Autoscaling
#

resource "aws_appautoscaling_target" "main" {
  depends_on = [data.aws_ecs_service.main]

  count = local.create_appautoscaling ? 1 : 0

  service_namespace  = "ecs"
  resource_id        = "service/${local.cluster_name}/${local.service_name}"
  scalable_dimension = var.aws_appautoscaling_target.scalable_dimension

  min_capacity = var.aws_appautoscaling_target.min_capacity
  max_capacity = var.aws_appautoscaling_target.max_capacity
}

resource "aws_appautoscaling_policy" "policies" {
  depends_on = [aws_appautoscaling_target.main]

  count = local.create_appautoscaling ? length(var.aws_appautoscaling_policy) : 0

  name               = var.aws_appautoscaling_policy[count.index].name
  service_namespace  = "ecs"
  resource_id        = "service/${local.cluster_name}/${local.service_name}"
  scalable_dimension = var.aws_appautoscaling_policy[count.index].scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = var.aws_appautoscaling_policy[count.index].adjustment_type
    cooldown                = var.aws_appautoscaling_policy[count.index].cooldown
    metric_aggregation_type = var.aws_appautoscaling_policy[count.index].metric_aggregation_type

    step_adjustment {
      metric_interval_lower_bound = var.aws_appautoscaling_policy[count.index].metric_interval_lower_bound
      metric_interval_upper_bound = var.aws_appautoscaling_policy[count.index].metric_interval_upper_bound
      scaling_adjustment          = var.aws_appautoscaling_policy[count.index].scaling_adjustment
    }
  }
}
