output "iam-id" {
  value = "${aws_iam_role.fargate.id}"
}

output "role-arn" {
  value = "${aws_iam_role.fargate.arn}"
}
