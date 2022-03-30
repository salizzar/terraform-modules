output "lb-arn" {
  value = aws_lb.lb.arn
}

output "lb-name" {
  value = aws_lb.lb.name
}

output "lb-arn-suffix" {
  value = aws_lb.lb.arn_suffix
}

output "tg-arn" {
  value = aws_lb_target_group.tg.arn
}

output "tg-arn-suffix" {
  value = aws_lb_target_group.tg.arn_suffix
}

output "lb-availability-zones" {
  value = data.aws_subnet.lb.*.availability_zone
}

output "sg-id" {
  value = aws_security_group.lb.id
}

output "lb-subnet-ids" {
  value = data.aws_subnet.lb.*.id
}

output "lb-dns-name" {
  value = aws_lb.lb.dns_name
}

output "lb-zone-id" {
  value = aws_lb.lb.zone_id
}
