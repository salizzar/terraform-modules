resource "aws_security_group" "swarm" {
  name   = "${var.aws_security_group["name"]}"
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    Name           = "${var.aws_security_group["tags_name"]}"
    VirtualNetwork = "${data.aws_vpc.vpc.tags["Name"]}"
    Environment    = "${terraform.workspace}"
    CreatedBy      = "terraform"
  }
}

resource "aws_security_group_rule" "ingress-http" {
  security_group_id = "${aws_security_group.swarm.id}"

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  description = "Docker Swarm - Allow HTTP"
  cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "ingress-https" {
  security_group_id = "${aws_security_group.swarm.id}"

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = "Docker Swarm - Allow HTTPS"
  cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "ingress-traefik" {
  security_group_id = "${aws_security_group.swarm.id}"

  # traefik panel
  type        = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  description = "Docker Swarm - Traefik console"
  cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "ingress-swarm-2377-tcp" {
  security_group_id = "${aws_security_group.swarm.id}"

  # swarm
  type        = "ingress"
  from_port   = 2377
  to_port     = 2377
  protocol    = "tcp"
  description = "Docker Swarm - Internal"
  cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "ingress-swarm-4789-tcp" {
  security_group_id = "${aws_security_group.swarm.id}"

  # swarm
  type        = "ingress"
  from_port   = 4789
  to_port     = 4789
  protocol    = "tcp"
  description = "Docker Swarm - Internal"
  cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "ingress-swarm-4789-udp" {
  security_group_id = "${aws_security_group.swarm.id}"

  # swarm
  type        = "ingress"
  from_port   = 4789
  to_port     = 4789
  protocol    = "udp"
  description = "Docker Swarm - Internal"
  cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "ingress-swarm-7946-tcp" {
  security_group_id = "${aws_security_group.swarm.id}"

  # swarm
  type        = "ingress"
  from_port   = 7946
  to_port     = 7946
  protocol    = "tcp"
  description = "Docker Swarm - Internal"
  cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "ingress-swarm-7946-udp" {
  security_group_id = "${aws_security_group.swarm.id}"

  # swarm
  type        = "ingress"
  from_port   = 7946
  to_port     = 7946
  protocol    = "udp"
  description = "Docker Swarm - Internal"
  cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
}

resource "aws_security_group_rule" "egress-swarm" {
  security_group_id = "${aws_security_group.swarm.id}"

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  description = "Docker Swarm - Outbound access to the world"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "mgr" {
  count = "${var.aws_instance_mgr["count"]}"

  instance_type = "${var.aws_instance_mgr["instance_type"]}"
  key_name      = "${var.aws_instance_mgr["key_name"]}"
  ami           = "${var.aws_instance_mgr["ami"]}"
  ebs_optimized = "${var.aws_instance_mgr["ebs_optimized"]}"

  vpc_security_group_ids  = ["${aws_security_group.swarm.id}", "${split(", ", var.aws_instance_mgr["vpc_security_group_ids"])}"]
  subnet_id               = "${element(data.aws_subnet.mgr.*.id, count.index)}"
  disable_api_termination = true

  root_block_device {
    volume_type           = "${var.aws_instance_mgr["root_block_device_volume_type"]}"
    volume_size           = "${var.aws_instance_mgr["root_block_device_volume_size"]}"
    delete_on_termination = "${var.aws_instance_mgr["root_block_device_delete_on_termination"]}"
  }

  tags = {
    Name           = "${var.aws_instance_mgr["tags_name"]}"
    VirtualNetwork = "${data.aws_vpc.vpc.tags["Name"]}"
    Environment    = "${terraform.workspace}"
    AnsibleID      = "${var.aws_instance_mgr["tags_name"]}_${terraform.workspace}"
    Type           = "docker-swarm"
    Role           = "swarm-manager"
    CreatedBy      = "terraform"
  }
}

resource "aws_instance" "wkr" {
  count = "${var.aws_instance_wkr["count"]}"

  instance_type = "${var.aws_instance_wkr["instance_type"]}"
  key_name      = "${var.aws_instance_wkr["key_name"]}"
  ami           = "${var.aws_instance_wkr["ami"]}"
  ebs_optimized = "${var.aws_instance_wkr["ebs_optimized"]}"

  vpc_security_group_ids  = ["${aws_security_group.swarm.id}", "${split(", ", var.aws_instance_mgr["vpc_security_group_ids"])}"]
  subnet_id               = "${element(data.aws_subnet.wkr.*.id, count.index)}"
  disable_api_termination = true

  root_block_device {
    volume_type           = "${var.aws_instance_wkr["root_block_device_volume_type"]}"
    volume_size           = "${var.aws_instance_wkr["root_block_device_volume_size"]}"
    delete_on_termination = "${var.aws_instance_wkr["root_block_device_delete_on_termination"]}"
  }

  tags = {
    Name           = "${var.aws_instance_wkr["tags_name"]}"
    VirtualNetwork = "${data.aws_vpc.vpc.tags["Name"]}"
    Environment    = "${terraform.workspace}"
    AnsibleID      = "${var.aws_instance_wkr["tags_name"]}_${terraform.workspace}"
    Type           = "docker-swarm"
    Role           = "swarm-worker"
    CreatedBy      = "terraform"
  }
}
