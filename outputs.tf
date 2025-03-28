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
  value = var.artifact_bucket_enabled ? aws_s3_bucket.artifact[0] : ""
}

output "dbpassword" {
  value = var.need_db == 1 ? random_string.dbpassword[0].result : null
}

output "password" {
  value = var.need_db == 1 ? random_string.password[0].result : null
}
