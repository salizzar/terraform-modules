# internal security group

resource "aws_security_group" "internal" {
  depends_on = ["aws_instance.bastion"]

  name        = "${var.aws_security_group_internal["name"]}"
  description = "Allows SSH access from bastion to servers inside VPC"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags = {
    Name           = "${var.aws_security_group_internal["tags_name"]}"
    VirtualNetwork = "${data.aws_vpc.vpc.tags["Name"]}"
    Environment    = "${terraform.workspace}"
    CreatedBy      = "terraform"
  }
}

resource "aws_security_group_rule" "internal-ingress-ssh" {
  security_group_id = "${aws_security_group.internal.id}"

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  description = "Internal - Allow SSH only from bastion private IP"
  cidr_blocks = ["${aws_instance.bastion.private_ip}/32"]
}

resource "aws_security_group_rule" "internal-egress-http" {
  security_group_id = "${aws_security_group.internal.id}"

  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  description = "Internal - Allow HTTP to the world"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "internal-egress-https" {
  security_group_id = "${aws_security_group.internal.id}"

  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  description = "Internal - Allow HTTPS to the world"
  cidr_blocks = ["0.0.0.0/0"]
}

# bastion public ip

resource "aws_eip" "bastion" {
  vpc      = true
  instance = "${aws_instance.bastion.id}"
}

# bastion security group

resource "aws_security_group" "bastion" {
  name        = "${var.aws_security_group_bastion["name"]}"
  description = "Allows access from world to bastion"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags = {
    Name           = "${var.aws_security_group_bastion["tags_name"]}"
    VirtualNetwork = "${data.aws_vpc.vpc.tags["Name"]}"
    Environment    = "${terraform.workspace}"
    CreatedBy      = "terraform"
  }
}

resource "aws_security_group_rule" "ingress-ssh" {
  count = "${length(var.aws_security_group_rule_ingress_ssh_bastion)}"

  security_group_id = "${aws_security_group.bastion.id}"

  type        = "ingress"
  protocol    = "tcp"
  description = "${element(var.aws_security_group_rule_ingress_ssh_bastion, count.index).description}"
  from_port   = 22
  to_port     = 22
  cidr_blocks = "${element(var.aws_security_group_rule_ingress_ssh_bastion, count.index).cidr_blocks}"
}

resource "aws_security_group_rule" "egress-http" {
  security_group_id = "${aws_security_group.bastion.id}"

  type        = "egress"
  protocol    = "tcp"
  description = "Allow HTTP to the world"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress-https" {
  security_group_id = "${aws_security_group.bastion.id}"

  type        = "egress"
  protocol    = "tcp"
  description = "Allow HTTPS to the world"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress-vpc" {
  security_group_id = "${aws_security_group.bastion.id}"

  type        = "egress"
  protocol    = "-1"
  description = "Allow traffic to VPC CIDR block"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
}

# bastion keypair

resource "aws_key_pair" "bastion" {
  key_name   = "${var.aws_key_pair["key_name"]}"
  public_key = "${var.aws_key_pair["public_key"]}"
}

# bastion server

resource "aws_instance" "bastion" {
  instance_type = "${var.aws_instance["instance_type"]}"
  ami           = "${var.aws_instance["ami"]}"
  key_name      = "${var.aws_instance["key_name"]}"

  subnet_id              = "${var.aws_subnet["id"]}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  disable_api_termination = true

  tags = {
    Name           = "${var.aws_instance["tags_name"]}"
    VirtualNetwork = "${data.aws_vpc.vpc.tags["Name"]}"
    Environment    = "${terraform.workspace}"
    CreatedBy      = "terraform"
  }

  depends_on = ["aws_security_group.bastion"]
}

# DNS entry (if Route53 zone is available)

resource "aws_route53_record" "bastion" {
  count = "${var.aws_route53_record["enabled"] ? 1 : 0}"

  zone_id = "${data.aws_route53_zone.main[0].zone_id}"
  name    = "${var.aws_route53_record["name"]}"
  type    = "A"
  ttl     = "${var.aws_route53_record["ttl"]}"

  records = ["${aws_eip.bastion.public_ip}"]
}
