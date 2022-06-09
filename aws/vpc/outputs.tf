output "vpc-id" {
  value = aws_vpc.vpc.id
}

# public

output "pub-rt-id" {
  value = aws_route_table.pub.id
}

output "prv-rt-id" {
  value = aws_route_table.prv.*.id
}

output "pub-dmz-subnet-ids" {
  value = aws_subnet.pub-dmz.*.id
}

output "pub-alb-subnet-ids" {
  value = aws_subnet.pub-alb.*.id
}

output "pub-docker-subnet-ids" {
  value = aws_subnet.pub-docker.*.id
}

output "pub-ec2-subnet-ids" {
  value = aws_subnet.pub-ec2.*.id
}

output "pub-ecs-subnet-ids" {
  value = aws_subnet.pub-ecs.*.id
}

output "pub-elasticache-subnet-ids" {
  value = aws_subnet.pub-elasticache.*.id
}

output "pub-elasticsearch-subnet-ids" {
  value = aws_subnet.pub-elasticsearch.*.id
}

output "pub-lambda-subnet-ids" {
  value = aws_subnet.pub-lambda.*.id
}

output "pub-rds-subnet-ids" {
  value = aws_subnet.pub-rds.*.id
}

# private

output "prv-alb-subnet-ids" {
  value = aws_subnet.prv-alb.*.id
}

output "prv-docker-subnet-ids" {
  value = aws_subnet.prv-docker.*.id
}

output "prv-ec2-subnet-ids" {
  value = aws_subnet.prv-ec2.*.id
}

output "prv-ecs-subnet-ids" {
  value = aws_subnet.prv-ecs.*.id
}

output "prv-elasticache-subnet-ids" {
  value = aws_subnet.prv-elasticache.*.id
}

output "prv-elasticsearch-subnet-ids" {
  value = aws_subnet.prv-elasticsearch.*.id
}

output "prv-lambda-subnet-ids" {
  value = aws_subnet.prv-lambda.*.id
}

output "prv-rds-subnet-ids" {
  value = aws_subnet.prv-rds.*.id
}
