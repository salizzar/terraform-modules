data "aws_lb_target_group" "tg" {
  count = local.service_is_exposed ? 1 : 0

  arn = var.aws_ecs_service.load_balancer.target_group_arn
}

data "aws_ecs_service" "main" {
  depends_on = [aws_ecs_service.main]

  service_name = aws_ecs_service.main.name
  cluster_arn  = aws_ecs_service.main.cluster
}
