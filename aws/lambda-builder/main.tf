variable "lambda" {
  type = object({
    source_path = string
    output_path = string
  })
}

data "external" "builder" {
  program = ["bash", "${path.module}/bin/build-lambda"]

  query = {
    root_folder = path.cwd
    lambda_path = var.lambda.source_path
  }
}

data "archive_file" "zip" {
  depends_on = [data.external.builder]

  type        = "zip"
  source_dir  = var.lambda.source_path
  output_path = var.lambda.output_path
}

output "output_base64sha256" {
  value = data.archive_file.zip.output_base64sha256
}
