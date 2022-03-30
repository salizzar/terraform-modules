locals {
  vpc_id = var.aws_vpc.id

  additional_tags = {
    Environment = terraform.workspace
  }
}

resource "aws_security_group" "traefik" {
  vpc_id = local.vpc_id
  name   = var.aws_security_group_traefik.name
  tags   = merge(var.aws_security_group_traefik.tags, local.additional_tags)
}

resource "aws_security_group_rule" "traefik" {
  count = length(var.aws_security_group_rule_traefik)

  security_group_id = aws_security_group.traefik.id

  type        = var.aws_security_group_rule_traefik[count.index].type
  from_port   = var.aws_security_group_rule_traefik[count.index].from_port
  to_port     = var.aws_security_group_rule_traefik[count.index].to_port
  protocol    = var.aws_security_group_rule_traefik[count.index].protocol
  description = var.aws_security_group_rule_traefik[count.index].description
  cidr_blocks = var.aws_security_group_rule_traefik[count.index].cidr_blocks
}

resource "aws_security_group" "traefik-apps" {
  name   = var.aws_security_group_traefik_apps.name
  vpc_id = local.vpc_id
  tags   = merge(var.aws_security_group_traefik_apps.tags, local.additional_tags)
}

resource "aws_security_group_rule" "traefik-apps" {
  count = length(var.aws_security_group_rule_traefik_apps)

  security_group_id = aws_security_group.traefik-apps.id

  type        = var.aws_security_group_rule_traefik_apps[count.index].type
  from_port   = var.aws_security_group_rule_traefik_apps[count.index].from_port
  to_port     = var.aws_security_group_rule_traefik_apps[count.index].to_port
  protocol    = var.aws_security_group_rule_traefik_apps[count.index].protocol
  description = var.aws_security_group_rule_traefik_apps[count.index].description
  cidr_blocks = var.aws_security_group_rule_traefik_apps[count.index].cidr_blocks
}
