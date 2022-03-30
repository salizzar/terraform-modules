data "aws_route53_zone" "main" {
  name = var.aws_route53_zone.name
}
