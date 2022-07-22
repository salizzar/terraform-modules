data "template_file" "payload" {
  template = file("${path.module}/src/lib/payload.ts.tpl")

  vars = {
    payload = var.cloudwatch_dashboards.payload
  }
}

resource "local_file" "payload" {
  filename        = "${path.module}/src/lib/payload.ts"
  content         = data.template_file.payload.rendered
  file_permission = "666"
}

data "external" "cdk-bootstrap" {
  depends_on = [local_file.payload]

  program = ["bash", "${path.module}/bin/cdk-bootstrap"]

  query = {
    profile = var.cloudwatch_dashboards.profile
  }
}

data "external" "manifest" {
  depends_on = [
    local_file.payload,
    data.external.cdk-bootstrap
  ]

  program = ["bash", "${path.module}/bin/capture-cdk-manifest-attributes"]

  query = {
    manifest_path = "${path.module}/src/cdk.out/manifest.json"
  }
}

data "external" "cdk-cf-template" {
  depends_on = [
    local_file.payload,
    data.external.cdk-bootstrap,
    data.external.manifest
  ]

  program = ["bash", "${path.module}/bin/generate-cloudformation-template"]
}

resource "aws_ssm_parameter" "cdk" {
  depends_on = [
    local_file.payload,
    data.external.cdk-bootstrap,
    data.external.manifest,
    data.external.cdk-cf-template
  ]

  name  = data.external.manifest.result["bootstrapStackVersionSsmParameter"]
  type  = "String"
  value = data.external.manifest.result["requiresBootstrapStackVersion"]
}

resource "aws_cloudformation_stack" "dashboards" {
  depends_on = [
    local_file.payload,
    data.external.cdk-bootstrap,
    data.external.manifest,
    data.external.cdk-cf-template,
    aws_ssm_parameter.cdk
  ]

  name          = var.aws_cloudformation_stack.name
  template_body = data.external.cdk-cf-template.result["cloudformation_template"]
}
