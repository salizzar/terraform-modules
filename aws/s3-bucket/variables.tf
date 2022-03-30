variable "aws_iam_policy_document" {
  type = object({
    statement_allow_access_key_administrators = list(string)
  })
}

variable "aws_kms_key" {
  type = object({
    enabled                 = bool
    description             = string
    deletion_window_in_days = number
    tags                    = map(string)
  })

  default = {
    enabled                 = false
    description             = ""
    deletion_window_in_days = 10
    tags                    = {}
  }
}

variable "aws_kms_alias" {
  type = object({
    name = string
  })
}

variable "aws_s3_bucket" {
  type = object({
    bucket = string
    acl    = string
    tags   = map(string)

    versioning = object({
      enabled = bool
    })

    website = object({
      index_document           = string
      error_document           = string
      redirect_all_requests_to = string
      routing_rules            = string
    })
  })
}

variable "aws_s3_bucket_policy" {
  type = object({
    enabled = bool
    policy  = string
  })

  default = {
    enabled = false
    policy  = ""
  }
}

variable "aws_s3_bucket_public_access_block" {
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })

  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "aws_dynamodb_table" {
  type = object({
    enabled        = bool
    name           = string
    read_capacity  = number
    write_capacity = number
    tags           = map(string)
  })

  default = {
    enabled        = false
    name           = ""
    read_capacity  = 20
    write_capacity = 20
    tags           = {}
  }
}
