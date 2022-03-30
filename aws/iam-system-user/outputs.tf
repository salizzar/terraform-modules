output "iam-user-id" {
  value = aws_iam_user.user.id
}

output "iam-user-arn" {
  value = aws_iam_user.user.arn
}

output "iam-role-arn" {
  value = aws_iam_role.role.arn
}

output "iam-access-key-id" {
  value = aws_iam_access_key.access-key.id
}

output "iam-secret-access-key" {
  value = aws_iam_access_key.access-key.encrypted_secret
}
