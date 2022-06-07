data "aws_route53_zone" "main" {
  provider = aws.dns
  name     = var.aws_route53_zone.name
}
