output "service-name" {
  value = local.service_name
}

output "appautoscaling-policy-arn" {
  value = aws_appautoscaling_policy.policies.*.arn
}
