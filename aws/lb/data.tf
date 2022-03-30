data "aws_vpc" "vpc" {
  id = var.aws_vpc.id
}

data "aws_subnet" "lb" {
  count = length(var.aws_lb.subnets)

  id = var.aws_lb.subnets[count.index]
}
