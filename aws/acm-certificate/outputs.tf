output "certificate-id" {
  value = "${aws_acm_certificate.cert.id}"
}

output "certificate-domain-name" {
  value = "${aws_acm_certificate.cert.domain_name}"
}

output "certificate-domain-validation-options" {
  value = "${aws_acm_certificate.cert.domain_validation_options}"
}
