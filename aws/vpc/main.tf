locals {
  additional_tags = {
    Environment = terraform.workspace
    CreatedBy   = "terraform"
  }
}

# vpc

resource "aws_vpc" "vpc" {
  cidr_block = var.aws_vpc.cidr_block

  enable_dns_support   = var.aws_vpc.enable_dns_support
  enable_dns_hostnames = var.aws_vpc.enable_dns_hostnames

  tags = merge(var.aws_vpc.tags, local.additional_tags)
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    aws_vpc.vpc.tags,
    { Name = "${var.aws_vpc.name}_igw" }
  )
}

resource "aws_nat_gateway" "default" {
  depends_on = [aws_internet_gateway.default]

  count = var.aws_nat_gateway.count

  allocation_id = element(aws_eip.eip_nat.*.id, count.index)
  subnet_id     = element(aws_subnet.pub-dmz.*.id, count.index)

  tags = merge(
    aws_vpc.vpc.tags,
    { Name = "${var.aws_vpc.tags.Name}_ngw" }
  )
}

resource "aws_eip" "eip_nat" {
  depends_on = [aws_internet_gateway.default]

  count = var.aws_nat_gateway.count

  vpc = true

  tags = merge(
    aws_vpc.vpc.tags,
    { Name = "${var.aws_vpc.tags.Name}_eip" }
  )
}

# public subnets

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    aws_vpc.vpc.tags,
    { Name = "${aws_vpc.vpc.tags.Name}_rt_pub" }
  )
}

resource "aws_route" "igw" {
  depends_on = [aws_route_table.pub]

  route_table_id         = aws_route_table.pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "pub-dmz" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.pub.dmz.cidr_blocks)

  cidr_block              = element(var.aws_subnet.pub.dmz.cidr_blocks, count.index)
  availability_zone       = element(var.aws_subnet.pub.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_pub_dmz"
      Scope = "public"
      Type  = "dmz"
  })
}

resource "aws_subnet" "pub-alb" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.pub.alb.cidr_blocks)

  cidr_block              = element(var.aws_subnet.pub.alb.cidr_blocks, count.index)
  availability_zone       = element(var.aws_subnet.pub.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_pub_alb"
      Scope = "public"
      Type  = "alb"
  })
}

resource "aws_subnet" "pub-docker" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.pub.docker.cidr_blocks)

  cidr_block              = element(var.aws_subnet.pub.docker.cidr_blocks, count.index)
  availability_zone       = element(var.aws_subnet.pub.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_pub_dkr"
      Scope = "public"
      Type  = "docker"
  })
}

resource "aws_subnet" "pub-ec2" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.pub.ec2.cidr_blocks)

  cidr_block              = element(var.aws_subnet.pub.ec2.cidr_blocks, count.index)
  availability_zone       = element(var.aws_subnet.pub.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_pub_ec2"
      Scope = "public"
      Type  = "ec2"
  })
}

resource "aws_subnet" "pub-ecs" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.pub.ecs.cidr_blocks)

  cidr_block              = element(var.aws_subnet.pub.ecs.cidr_blocks, count.index)
  availability_zone       = element(var.aws_subnet.pub.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_pub_ecs"
      Scope = "public"
      Type  = "ecs"
  })
}

resource "aws_subnet" "pub-elasticache" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.pub.elasticache.cidr_blocks)

  cidr_block              = element(var.aws_subnet.pub.elasticache.cidr_blocks, count.index)
  availability_zone       = element(var.aws_subnet.pub.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_pub_elasticache"
      Scope = "public"
      Type  = "elasticache"
  })
}

resource "aws_subnet" "pub-elasticsearch" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.pub.elasticsearch.cidr_blocks)

  cidr_block              = element(var.aws_subnet.pub.elasticsearch.cidr_blocks, count.index)
  availability_zone       = element(var.aws_subnet.pub.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_pub_elasticsearch"
      Scope = "public"
      Type  = "elasticsearch"
  })
}

resource "aws_subnet" "pub-lambda" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.pub.lambda.cidr_blocks)

  cidr_block              = element(var.aws_subnet.pub.lambda.cidr_blocks, count.index)
  availability_zone       = element(var.aws_subnet.pub.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_pub_lambda"
      Scope = "public"
      Type  = "lambda"
  })
}

resource "aws_subnet" "pub-rds" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.pub.rds.cidr_blocks)

  cidr_block              = element(var.aws_subnet.pub.rds.cidr_blocks, count.index)
  availability_zone       = element(var.aws_subnet.pub.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_pub_rds"
      Scope = "public"
      Type  = "rds"
  })
}

resource "aws_route_table_association" "pub-dmz" {
  count = length(var.aws_subnet.pub.dmz.cidr_blocks)

  subnet_id      = element(aws_subnet.pub-dmz.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub-alb" {
  count = length(var.aws_subnet.pub.alb.cidr_blocks)

  subnet_id      = element(aws_subnet.pub-alb.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub-docker" {
  count = length(var.aws_subnet.pub.docker.cidr_blocks)

  subnet_id      = element(aws_subnet.pub-docker.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub-ec2" {
  count = length(var.aws_subnet.pub.ec2.cidr_blocks)

  subnet_id      = element(aws_subnet.pub-ec2.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub-ecs" {
  count = length(var.aws_subnet.pub.ecs.cidr_blocks)

  subnet_id      = element(aws_subnet.pub-ecs.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub-elasticache" {
  count = length(var.aws_subnet.pub.elasticache.cidr_blocks)

  subnet_id      = element(aws_subnet.pub-elasticache.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub-elasticsearch" {
  count = length(var.aws_subnet.pub.elasticsearch.cidr_blocks)

  subnet_id      = element(aws_subnet.pub-elasticsearch.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub-lambda" {
  count = length(var.aws_subnet.pub.lambda.cidr_blocks)

  subnet_id      = element(aws_subnet.pub-lambda.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub-rds" {
  count = length(var.aws_subnet.pub.rds.cidr_blocks)

  subnet_id      = element(aws_subnet.pub-rds.*.id, count.index)
  route_table_id = aws_route_table.pub.id
}

# private subnets

resource "aws_route_table" "prv" {
  depends_on = [aws_nat_gateway.default]

  count = length(aws_nat_gateway.default)

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    aws_vpc.vpc.tags,
    { Name = "${aws_vpc.vpc.tags.Name}_rt_prv" }
  )
}

resource "aws_route" "nat" {
  depends_on = [aws_route_table.prv]

  count = length(aws_nat_gateway.default)

  route_table_id         = element(aws_route_table.prv.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.default.*.id, count.index)
}

resource "aws_subnet" "prv-alb" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.prv.alb.cidr_blocks)

  cidr_block        = element(var.aws_subnet.prv.alb.cidr_blocks, count.index)
  availability_zone = element(var.aws_subnet.prv.availability_zones, count.index)

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_prv_alb"
      Scope = "private"
      Type  = "alb"
  })
}

resource "aws_subnet" "prv-docker" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.prv.docker.cidr_blocks)

  cidr_block        = element(var.aws_subnet.prv.docker.cidr_blocks, count.index)
  availability_zone = element(var.aws_subnet.prv.availability_zones, count.index)

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_prv_dkr"
      Scope = "private"
      Type  = "docker"
  })
}

resource "aws_subnet" "prv-ec2" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.prv.ec2.cidr_blocks)

  cidr_block        = element(var.aws_subnet.prv.ec2.cidr_blocks, count.index)
  availability_zone = element(var.aws_subnet.prv.availability_zones, count.index)

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_prv_ec2"
      Scope = "private"
      Type  = "ec2"
  })
}

resource "aws_subnet" "prv-ecs" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.prv.ecs.cidr_blocks)

  cidr_block        = element(var.aws_subnet.prv.ecs.cidr_blocks, count.index)
  availability_zone = element(var.aws_subnet.prv.availability_zones, count.index)

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_prv_ecs"
      Scope = "private"
      Type  = "ecs"
  })
}

resource "aws_subnet" "prv-elasticache" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.prv.elasticache.cidr_blocks)

  cidr_block        = element(var.aws_subnet.prv.elasticache.cidr_blocks, count.index)
  availability_zone = element(var.aws_subnet.prv.availability_zones, count.index)

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_prv_elasticache"
      Scope = "private"
      Type  = "elasticache"
  })
}

resource "aws_subnet" "prv-elasticsearch" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.prv.elasticsearch.cidr_blocks)

  cidr_block        = element(var.aws_subnet.prv.elasticsearch.cidr_blocks, count.index)
  availability_zone = element(var.aws_subnet.prv.availability_zones, count.index)

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_prv_elasticsearch"
      Scope = "private"
      Type  = "elasticsearch"
  })
}

resource "aws_subnet" "prv-lambda" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.prv.lambda.cidr_blocks)

  cidr_block        = element(var.aws_subnet.prv.lambda.cidr_blocks, count.index)
  availability_zone = element(var.aws_subnet.prv.availability_zones, count.index)

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_prv_lambda"
      Scope = "private"
      Type  = "lambda"
  })
}

resource "aws_subnet" "prv-rds" {
  vpc_id = aws_vpc.vpc.id

  count = length(var.aws_subnet.prv.rds.cidr_blocks)

  cidr_block        = element(var.aws_subnet.prv.rds.cidr_blocks, count.index)
  availability_zone = element(var.aws_subnet.prv.availability_zones, count.index)

  tags = merge(
    aws_vpc.vpc.tags,
    {
      Name  = "${aws_vpc.vpc.tags.Name}_prv_rds"
      Scope = "private"
      Type  = "rds"
  })
}

resource "aws_route_table_association" "prv-alb" {
  count = length(var.aws_subnet.prv.alb.cidr_blocks)

  subnet_id      = element(aws_subnet.prv-alb.*.id, count.index)
  route_table_id = element(aws_route_table.prv.*.id, count.index)
}

resource "aws_route_table_association" "prv-docker" {
  count = length(var.aws_subnet.prv.docker.cidr_blocks)

  subnet_id      = element(aws_subnet.prv-docker.*.id, count.index)
  route_table_id = element(aws_route_table.prv.*.id, count.index)
}

resource "aws_route_table_association" "prv-ec2" {
  count = length(var.aws_subnet.prv.ec2.cidr_blocks)

  subnet_id      = element(aws_subnet.prv-ec2.*.id, count.index)
  route_table_id = element(aws_route_table.prv.*.id, count.index)
}

resource "aws_route_table_association" "prv-ecs" {
  count = length(var.aws_subnet.prv.ecs.cidr_blocks)

  subnet_id      = element(aws_subnet.prv-ecs.*.id, count.index)
  route_table_id = element(aws_route_table.prv.*.id, count.index)
}

resource "aws_route_table_association" "prv-elasticache" {
  count = length(var.aws_subnet.prv.elasticache.cidr_blocks)

  subnet_id      = element(aws_subnet.prv-elasticache.*.id, count.index)
  route_table_id = element(aws_route_table.prv.*.id, count.index)
}

resource "aws_route_table_association" "prv-elasticsearch" {
  count = length(var.aws_subnet.prv.elasticsearch.cidr_blocks)

  subnet_id      = element(aws_subnet.prv-elasticsearch.*.id, count.index)
  route_table_id = element(aws_route_table.prv.*.id, count.index)
}

resource "aws_route_table_association" "prv-lambda" {
  count = length(var.aws_subnet.prv.lambda.cidr_blocks)

  subnet_id      = element(aws_subnet.prv-lambda.*.id, count.index)
  route_table_id = element(aws_route_table.prv.*.id, count.index)
}

resource "aws_route_table_association" "prv-rds" {
  count = length(var.aws_subnet.prv.rds.cidr_blocks)

  subnet_id      = element(aws_subnet.prv-rds.*.id, count.index)
  route_table_id = element(aws_route_table.prv.*.id, count.index)
}
