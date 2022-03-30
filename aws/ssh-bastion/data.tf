data "aws_vpc" "vpc" {
  id = "${var.aws_vpc["id"]}"
}

data "aws_route53_zone" "main" {
  count = "${var.aws_route53_record["enabled"] ? 1 : 0}"

  name = "${var.aws_route53_record["zone"]}"
}
