variable "aws_key_pair" {
  type = "map"

  default = {
    key_name   = ""
    public_key = ""
  }
}
