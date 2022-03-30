output "traefik-sg-id" {
  value = aws_security_group.traefik.id
}

output "traefik-apps-sg-id" {
  value = aws_security_group.traefik-apps.id
}
