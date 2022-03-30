locals {
  additional_tags = {
    Environment = terraform.workspace
  }
}

resource "aws_lb_target_group" "traefik" {
  vpc_id      = data.aws_vpc.vpc.id
  name        = var.aws_lb_target_group.name
  port        = var.aws_lb_target_group.port
  protocol    = var.aws_lb_target_group.protocol
  target_type = var.aws_lb_target_group.target_type

  health_check {
    protocol            = var.aws_lb_target_group.health_check.protocol
    interval            = var.aws_lb_target_group.health_check.interval
    path                = var.aws_lb_target_group.health_check.path
    healthy_threshold   = var.aws_lb_target_group.health_check.healthy_threshold
    unhealthy_threshold = var.aws_lb_target_group.health_check.unhealthy_threshold
    timeout             = var.aws_lb_target_group.health_check.timeout
    matcher             = var.aws_lb_target_group.health_check.matcher
  }

  tags = merge(var.aws_lb_target_group.tags, local.additional_tags)
}

resource "aws_lb_listener" "traefik" {
  depends_on = [aws_lb_target_group.traefik, data.aws_lb.lb]

  load_balancer_arn = data.aws_lb.lb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.traefik.arn
    type             = "forward"
  }
}

resource "aws_security_group_rule" "ingress-traefik" {
  count = length(var.aws_security_group_rule.inbound)

  security_group_id = var.aws_security_group_rule.security_group_id

  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  description = var.aws_security_group_rule.inbound[count.index].description
  cidr_blocks = var.aws_security_group_rule.inbound[count.index].cidr_blocks
}

resource "aws_security_group_rule" "egress-traefik" {
  count = length(var.aws_security_group_rule.outbound)

  security_group_id = var.aws_security_group_rule.security_group_id

  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  description = var.aws_security_group_rule.outbound[count.index].description
  cidr_blocks = var.aws_security_group_rule.outbound[count.index].cidr_blocks
}
