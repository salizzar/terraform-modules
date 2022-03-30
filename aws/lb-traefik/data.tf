data "aws_vpc" "vpc" {
  id = var.aws_vpc.id
}

data "aws_lb" "lb" {
  arn = var.aws_lb.arn
}
