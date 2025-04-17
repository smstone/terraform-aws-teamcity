resource "aws_iam_role" "teamcity-server" {
  name = "teamcity-server-role"
  description        = "TeamCity server IAM role, allows EC2 instances to call AWS services on your behalf."
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

resource "aws_iam_role_policy" "inline_assume_policy" {
  count = var.server_assume_role_arn == null ? 0 : 1
  name = "inline-assume-policy"
  role = aws_iam_role.teamcity-server.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Resource = var.server_assume_role_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "teamcity" {
  name = "teamcity-server"
  role = aws_iam_role.teamcity-server.name
}
