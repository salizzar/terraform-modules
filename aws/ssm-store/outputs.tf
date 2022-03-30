output "kms-arn" {
  value = "${aws_kms_key.kms.arn}"
}

output "kms-id" {
  value = "${aws_kms_key.kms.id}"
}
