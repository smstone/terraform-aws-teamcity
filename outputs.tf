output "server" {
  value = aws_instance.teamcity
}

output "elb" {
  value = aws_elb.service_elb
}

output "teamcity_db" {
  value = aws_db_instance.teamcity
}

output "artifact-bucket" {
  value = var.artifact_bucket_enabled ? aws_s3_bucket[0].artifact : ""
}

output "dbpassword" {
  value = random_string.dbpassword.result
}

output "password" {
  value = random_string.password.result
}
