resource "aws_lb_target_group_attachment" "tga" {
  count = "${length(var.aws_instance_ids)}"

  target_group_arn = "${data.aws_lb_target_group.tg.arn}"
  target_id        = "${element(var.aws_instance_ids, count.index)}"
  port             = "${var.aws_lb_target_group_attachment["port"]}"
}
