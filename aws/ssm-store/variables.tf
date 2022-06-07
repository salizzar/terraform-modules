variable "aws_kms_key" {
  type = object({
    description             = string
    deletion_window_in_days = number
    tags                    = map(string)
  })
}

variable "aws_kms_alias" {
  type = object({
    name = string
  })
}

variable "aws_ssm_parameter" {
  type = object({
    application  = string
    cluster_name = string
    prefix       = string
    tags         = map(string)

    values = list(object({
      name  = string
      type  = string
      value = string
    }))
  })
}

variable "ecs_deployment" {
  type = object({
    cluster = string
    service = string
    profile = string
    region  = string
  })

  default = null
}
