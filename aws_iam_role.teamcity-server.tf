resource "aws_iam_role" "teamcity-server" {
  name = "teamcity-server-role"
  description        = "TeamCity server IAM role, allows EC2 instances to call AWS services on your behalf."

  inline_policy {
    name   = "teamcity-server-inline-policy"
    policy = file(var.iam_role_inline_policy)
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
