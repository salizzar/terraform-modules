locals {
  additional_tags = {
    Environment = terraform.workspace
  }
}

resource "aws_iam_user" "user" {
  name = var.aws_iam_user.name
  path = var.aws_iam_user.path
  tags = merge(var.aws_iam_user.tags, local.additional_tags)
}

resource "aws_iam_access_key" "access-key" {
  user    = aws_iam_user.user.name
  pgp_key = var.aws_iam_access_key.pgp_key
}

resource "aws_iam_role" "role" {
  name               = var.aws_iam_role.name
  assume_role_policy = var.aws_iam_role.assume_role_policy
  tags               = merge(var.aws_iam_role.tags, local.additional_tags)
}

resource "aws_iam_role_policy" "policy" {
  name   = var.aws_iam_role_policy.name
  policy = var.aws_iam_role_policy.policy
  role   = aws_iam_role.role.name
}

resource "aws_iam_user_policy" "user-policy" {
  name   = var.aws_iam_user_policy.name
  user   = aws_iam_user.user.name
  policy = aws_iam_role_policy.policy.policy
}

