data "aws_alb_target_group" "tg" {
  arn = "${var.aws_alb_target_group["arn"]}"
}
