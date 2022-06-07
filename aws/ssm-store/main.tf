locals {
  default_deletion_window_in_days = 7

  application_path        = "${var.aws_ssm_parameter.prefix}/${var.aws_ssm_parameter.application}"
  deletion_window_in_days = lookup(var.aws_kms_key, "deletion_window_in_days", local.default_deletion_window_in_days)

  awscli_profile_args = var.ecs_deployment != null ? format("--profile %s --region %s", var.ecs_deployment.profile, var.ecs_deployment.region) : ""

  additional_tags = {
    Environment = terraform.workspace
  }
}

resource "aws_kms_key" "kms" {
  description             = var.aws_kms_key.description
  deletion_window_in_days = local.deletion_window_in_days
  policy                  = data.aws_iam_policy_document.kms-policy.json
  tags                    = merge(var.aws_kms_key.tags, local.additional_tags)
}

resource "aws_kms_alias" "alias" {
  name          = var.aws_kms_alias.name
  target_key_id = aws_kms_key.kms.key_id
}

resource "aws_ssm_parameter" "values" {
  count = length(var.aws_ssm_parameter.values)

  name        = "${local.application_path}/${var.aws_ssm_parameter.values[count.index].name}"
  type        = var.aws_ssm_parameter.values[count.index].type
  value       = var.aws_ssm_parameter.values[count.index].value
  description = lookup(element(var.aws_ssm_parameter.values, count.index), "description", "")
  key_id      = var.aws_ssm_parameter.values[count.index].type == "SecureString" ? aws_kms_key.kms.key_id : ""
  overwrite   = true

  tags = merge(
    {
      Name        = var.aws_ssm_parameter.values[count.index].name
      Application = var.aws_ssm_parameter.application
      ClusterName = var.aws_ssm_parameter.cluster_name
    },
    var.aws_ssm_parameter.tags,
  local.additional_tags)
}

resource "null_resource" "deployment" {
  depends_on = [aws_ssm_parameter.values]

  count = var.ecs_deployment != null ? 1 : 0

  triggers = {
    trigger = base64sha512(join("|", aws_ssm_parameter.values.*.value))
  }

  provisioner "local-exec" {
    command = <<EOF
      aws ecs update-service --force-new-deployment --cluster ${var.ecs_deployment.cluster} --service ${var.ecs_deployment.service} ${local.awscli_profile_args}
    EOF
  }
}
