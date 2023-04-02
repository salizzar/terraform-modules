variable "aws_iam_policy_document" {
  type = object({
    statement_allow_access_key_administrators = list(string)
  })
}


#
# kms key
#


variable "aws_kms_key" {
  type = object({
    enabled                 = bool
    description             = string
    deletion_window_in_days = number
    enable_key_rotation     = bool
    tags                    = map(string)
  })

  default = {
    enabled                 = false
    description             = ""
    deletion_window_in_days = 10
    enable_key_rotation     = true
    tags                    = {}
  }
}

variable "aws_kms_alias" {
  type = object({
    name = string
  })
}


#
# s3 bucket
#


variable "aws_s3_bucket" {
  type = object({
    bucket = string
    tags   = map(string)
  })
}

variable "aws_s3_bucket_acl" {
  type = object({
    acl = string
  })
}

variable "aws_s3_bucket_versioning" {
  type = object({
    versioning_configuration = object({
      status = string
    })
  })
}

variable "aws_s3_bucket_website_configuration" {
  type = object({
    index_document = object({
      suffix = string
    })

    error_document = object({
      key = string
    })
  })
}

variable "aws_s3_bucket_server_side_encryption_configuration" {
  type = object({
    enabled = bool

    rules = list(object({
      sse_algorithm = string
    }))
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


#
# log bucket
#


variable "aws_s3_log_bucket" {
  type = object({
    enabled = bool
    bucket  = string
    tags    = map(string)
  })
}

variable "aws_s3_log_bucket_versioning" {
  type = object({
    versioning_configuration = object({
      status = string
    })
  })
}

variable "aws_s3_log_bucket_acl" {
  type = object({
    acl = string
  })
}

variable "aws_s3_bucket_logging" {
  type = object({
    target_prefix = string
  })
}


#
# dynamodb
#

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
