variable "aws_acm_certificate" {
  type = object({
    domain_name               = string
    subject_alternative_names = list(string)
    tags                      = map(string)
  })
}

variable "aws_route53_zone" {
  type = object({
    name = string
  })
}

variable "aws_route53_record" {
  type = object({
    allow_overwrite = bool
  })

  default = {
    allow_overwrite = false
  }
}
