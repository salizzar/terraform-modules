locals {
  domain_name               = var.aws_acm_certificate.domain_name
  wildcard_domain_name      = "*.${local.domain_name}"
  subject_alternative_names = var.aws_acm_certificate.subject_alternative_names
  alternative_domain_names  = local.subject_alternative_names

  all_domains       = split(", ", format("%s, %s", local.domain_name, join(", ", local.subject_alternative_names)))
  wildcard_exists   = contains(local.all_domains, local.wildcard_domain_name)
  validation_factor = local.wildcard_exists ? 1 : 0

  additional_tags = {
    Environment = terraform.workspace
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name               = local.domain_name
  subject_alternative_names = length(local.alternative_domain_names) > 0 ? local.alternative_domain_names : null
  validation_method         = "DNS"

  tags = merge(var.aws_acm_certificate.tags, local.additional_tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  depends_on = [aws_acm_certificate.cert]

  count = length(local.all_domains) - local.validation_factor

  zone_id = data.aws_route53_zone.main.id
  name    = element(aws_acm_certificate.cert.domain_validation_options, count.index).resource_record_name
  type    = element(aws_acm_certificate.cert.domain_validation_options, count.index).resource_record_type
  ttl     = 60

  records         = [element(aws_acm_certificate.cert.domain_validation_options, count.index).resource_record_value]
  allow_overwrite = var.aws_route53_record.allow_overwrite
}

resource "aws_acm_certificate_validation" "validation" {
  depends_on = [aws_route53_record.validation]

  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = aws_route53_record.validation.*.fqdn
}
