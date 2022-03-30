variable "aws_ssm_parameter_list" {
  type = list
}

variable "service_prefix" {
  type = string
}

data "template_file" "service_secrets" {
  count = length(var.aws_ssm_parameter_list)

  template = <<EOF
	{
		"name": "$${secret_name}",
		"valueFrom": "$${secret_path}"
	}
EOF

  vars = {
    secret_name = var.aws_ssm_parameter_list[count.index].name
    secret_path = "${var.service_prefix}/${var.aws_ssm_parameter_list[count.index].name}"
  }
}

output "rendered" {
  value = data.template_file.service_secrets.*.rendered
}
