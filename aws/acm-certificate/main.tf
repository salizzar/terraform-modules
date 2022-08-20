locals {
  domain_name               = var.aws_acm_certificate.domain_name
  wildcard_domain_name      = "*.${local.domain_name}"
  subject_alternative_names = var.aws_acm_certificate.subject_alternative_names
  alternative_domain_names  = local.subject_alternative_names

  all_domains       = split(", ", format("%s, %s", local.domain_name, join(", ", local.subject_alternative_names)))
  wildcard_exists   = contains(local.all_domains, local.wildcard_domain_name)
  validation_factor = local.wildcard_exists ? 1 : 0
}

resource "aws_acm_certificate" "cert" {
  provider = aws.src

  domain_name               = local.domain_name
  subject_alternative_names = length(local.alternative_domain_names) > 0 ? local.alternative_domain_names : null
  validation_method         = "DNS"

  tags = var.aws_acm_certificate.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  depends_on = [aws_acm_certificate.cert]

  provider = aws.dns

  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }

    if contains(concat([aws_acm_certificate.cert.domain_name], tolist(aws_acm_certificate.cert.subject_alternative_names)), "*.${dvo.domain_name}") == false
  }

  zone_id         = data.aws_route53_zone.main.id
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = 60
  allow_overwrite = var.aws_route53_record.allow_overwrite
}

resource "aws_acm_certificate_validation" "validation" {
  depends_on = [aws_route53_record.validation]

  provider = aws.dns

  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
