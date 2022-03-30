resource "aws_db_subnet_group" "rds" {
  name       = "${var.aws_db_subnet_group["name"]}"
  subnet_ids = "${data.aws_subnet.rds.*.id}"

  tags = {
    Name        = "${var.aws_db_subnet_group["tags_name"]}"
    Environment = "${terraform.workspace}"
    CreatedBy   = "terraform"
  }
}

resource "aws_security_group" "rds" {
  vpc_id                 = "${data.aws_vpc.vpc.id}"
  name                   = "${var.aws_security_group["name"]}"
  revoke_rules_on_delete = false

  tags = {
    Name        = "${var.aws_security_group["tags_name"]}"
    Environment = "${terraform.workspace}"
    CreatedBy   = "terraform"
  }
}

resource "aws_security_group_rule" "rules" {
  count = "${length(var.aws_security_group_rules)}"

  security_group_id = "${aws_security_group.rds.id}"

  type        = "${element(var.aws_security_group_rules, count.index).type}"
  from_port   = "${element(var.aws_security_group_rules, count.index).from_port}"
  to_port     = "${element(var.aws_security_group_rules, count.index).to_port}"
  protocol    = "${element(var.aws_security_group_rules, count.index).protocol}"
  cidr_blocks = "${split(", ", element(var.aws_security_group_rules, count.index).cidr_blocks)}"
}

resource "aws_db_instance" "rds" {
  allocated_storage       = "${var.aws_db_instance["allocated_storage"]}"
  backup_retention_period = "${var.aws_db_instance["backup_retention_period"]}"
  monitoring_interval     = "${var.aws_db_instance["monitoring_interval"]}"
  backup_window           = "${var.aws_db_instance["backup_window"]}"
  maintenance_window      = "${var.aws_db_instance["maintenance_window"]}"
  identifier              = "${var.aws_db_instance["identifier"]}"
  storage_type            = "${var.aws_db_instance["storage_type"]}"
  engine                  = "${var.aws_db_instance["engine"]}"
  engine_version          = "${var.aws_db_instance["engine_version"]}"
  instance_class          = "${var.aws_db_instance["instance_class"]}"
  name                    = "${var.aws_db_instance["name"]}"
  username                = "${var.aws_db_instance["username"]}"
  password                = "${var.aws_db_instance["password"]}"
  parameter_group_name    = "${var.aws_db_instance["parameter_group_name"]}"
  multi_az                = "${var.aws_db_instance["multi_az"]}"
  publicly_accessible     = "${var.aws_db_instance["publicly_accessible"]}"
  deletion_protection     = "${var.aws_db_instance["deletion_protection"]}"
  skip_final_snapshot     = "${var.aws_db_instance["skip_final_snapshot"]}"

  db_subnet_group_name   = "${aws_db_subnet_group.rds.name}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
}
