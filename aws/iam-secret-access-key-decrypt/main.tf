data "external" "decrypt" {
  program = ["${path.module}/bin/decrypt"]

  query = {
    secret = var.aws_iam_access_key.encrypted_secret
  }
}

variable "aws_iam_access_key" {
  type = object({
    encrypted_secret = string
  })
}

output "secret" {
  value = data.external.decrypt.result["secret"]
}
