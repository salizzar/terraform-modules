data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.aws_vpc["tags_name"]}"]
  }
}

data "aws_subnet_ids" "mgr" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    Kind = "${var.aws_subnet_ids_mgr["tags_kind"]}"
    Type = "${var.aws_subnet_ids_mgr["tags_type"]}"
  }
}

data "aws_subnet" "mgr" {
  count = "${length(data.aws_subnet_ids.mgr.ids)}"

  id = "${element(data.aws_subnet_ids.mgr.ids, count.index)}"
}

data "aws_subnet_ids" "wkr" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    Kind = "${var.aws_subnet_ids_wkr["tags_kind"]}"
    Type = "${var.aws_subnet_ids_wkr["tags_type"]}"
  }
}

data "aws_subnet" "wkr" {
  count = "${length(data.aws_subnet_ids.wkr.ids)}"

  id = "${element(data.aws_subnet_ids.wkr.ids, count.index)}"
}
