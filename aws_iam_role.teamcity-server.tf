resource "aws_iam_role" "teamcity-server" {
  name = "teamcity-server-role"
  description        = "TeamCity server IAM role, allows EC2 instances to call AWS services on your behalf."

  dynamic "inline_policy" {
    for_each = zipmap([for idx, arn in var.server_assume_role_arns : idx], var.server_assume_role_arns)
    content {
      name   = "inline-policy-${each.key}"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = "sts:AssumeRole"
            Effect   = "Allow"
            Resource = each.value
          }
        ]
      })
    }
  }

  assume_role_policy = <<HERE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
HERE
}

resource "aws_iam_instance_profile" "teamcity" {
  name = "teamcity-server"
  role = aws_iam_role.teamcity-server.name
}
