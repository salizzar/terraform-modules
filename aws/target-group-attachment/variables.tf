variable "aws_instance_ids" {
  type = "list"
}

variable "aws_lb_target_group" {
  type = "map"

  default = {
    arn = ""
  }
}

variable "aws_lb_target_group_attachment" {
  type = "map"

  default = {
    port = 0
  }
}
