output "server" {
  value = aws_instance.teamcity
}

output "alb" {
  value = aws_alb.service_alb
}
