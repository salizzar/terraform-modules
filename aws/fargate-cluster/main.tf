locals {
  additional_tags = {
    Environment = terraform.workspace
  }
}

resource "aws_ecs_cluster" "main" {
  name = var.aws_ecs_cluster.name
  tags = merge(var.aws_ecs_cluster.tags, local.additional_tags)
}
