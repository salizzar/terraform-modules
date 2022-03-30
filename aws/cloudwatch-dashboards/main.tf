data "template_file" "payload" {
  template = file("${path.module}/src/lib/payload.ts.tpl")

  vars = {
    payload = var.cloudwatch_dashboards.payload
  }
}

resource "local_file" "payload" {
  filename        = "${path.module}/src/lib/payload.ts"
  content         = data.template_file.payload.rendered
  file_permission = "444"
}

data "external" "cdk" {
  depends_on = [local_file.payload]

  program = ["bash", "${path.module}/bin/generate-cloudformation-template"]
}

resource "aws_cloudformation_stack" "dashboards" {
  name          = var.aws_cloudformation_stack.name
  template_body = data.external.cdk.result["cloudformation_template"]
}
