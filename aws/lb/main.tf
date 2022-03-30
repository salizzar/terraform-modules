locals {
  additional_tags = {
    Environment = terraform.workspace
    CreatedBy   = "terraform"
  }
}

resource "aws_lb" "lb" {
  name                       = var.aws_lb.name
  internal                   = var.aws_lb.internal
  subnets                    = var.aws_lb.subnets
  security_groups            = [aws_security_group.lb.id]
  enable_deletion_protection = var.aws_lb.enable_deletion_protection

  tags = merge(var.aws_lb.tags, local.additional_tags)
}

resource "aws_lb_target_group" "tg" {
  vpc_id      = data.aws_vpc.vpc.id
  name        = var.aws_lb_target_group.name
  port        = var.aws_lb_target_group.port
  protocol    = var.aws_lb_target_group.protocol
  target_type = var.aws_lb_target_group.target_type

  health_check {
    protocol            = var.aws_lb_target_group.health_check.protocol
    interval            = var.aws_lb_target_group.health_check.interval
    port                = var.aws_lb_target_group.health_check.port
    path                = var.aws_lb_target_group.health_check.path
    healthy_threshold   = var.aws_lb_target_group.health_check.healthy_threshold
    unhealthy_threshold = var.aws_lb_target_group.health_check.unhealthy_threshold
    timeout             = var.aws_lb_target_group.health_check.timeout
    matcher             = var.aws_lb_target_group.health_check.matcher
  }
}

resource "aws_lb_listener" "http" {
  depends_on = [aws_lb.lb, aws_lb_target_group.tg]

  count = var.aws_lb_listener.http_enabled ? 1 : 0

  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  depends_on = [aws_lb.lb, aws_lb_target_group.tg]

  count = var.aws_lb_listener.https_enabled ? 1 : 0

  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.aws_lb_listener.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

resource "aws_security_group" "lb" {
  vpc_id = data.aws_vpc.vpc.id
  name   = var.aws_security_group.name

  tags = merge(var.aws_security_group.tags, local.additional_tags)
}

resource "aws_security_group_rule" "rules" {
  count = length(var.aws_security_group_rules)

  security_group_id = aws_security_group.lb.id
  type              = element(var.aws_security_group_rules, count.index).type
  from_port         = element(var.aws_security_group_rules, count.index).from_port
  to_port           = element(var.aws_security_group_rules, count.index).to_port
  protocol          = element(var.aws_security_group_rules, count.index).protocol
  description       = element(var.aws_security_group_rules, count.index).description
  cidr_blocks       = element(var.aws_security_group_rules, count.index).cidr_blocks
}

resource "aws_route53_record" "lb" {
  count = var.aws_route53_record.create ? 1 : 0

  zone_id = var.aws_route53_record.zone_id
  name    = var.aws_route53_record.name
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = false
  }
}
