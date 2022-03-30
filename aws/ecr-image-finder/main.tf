variable "args" {
  type = object({
    aws_profile    = string
    ecr_repository = string
    ecr_image_id   = string
  })
}

data "external" "finder" {
  program = ["bash", "${path.module}/bin/finder"]

  query = {
    aws_profile    = var.args.aws_profile != null ? var.args.aws_profile : ""
    ecr_repository = var.args.ecr_repository
    ecr_image_id   = var.args.ecr_image_id
  }
}

output "result" {
  value = data.external.finder.result
}
