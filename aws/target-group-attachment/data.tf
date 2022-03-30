data "aws_lb_target_group" "tg" {
  arn = "${var.aws_lb_target_group["arn"]}"
}
