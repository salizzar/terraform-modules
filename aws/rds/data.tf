data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.aws_vpc["tags_name"]}"]
  }
}

data "aws_subnet_ids" "rds" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    Kind = "${var.aws_subnet_ids_rds["tags_kind"]}"
    Type = "${var.aws_subnet_ids_rds["tags_type"]}"
  }
}

data "aws_subnet" "rds" {
  count = "${length(data.aws_subnet_ids.rds.ids)}"

  id = "${element(tolist(data.aws_subnet_ids.rds.ids), count.index)}"
}
