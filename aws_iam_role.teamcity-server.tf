resource "aws_iam_role" "teamcity-server" {
  description        = "Allows EC2 instances to call AWS services on your behalf."
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
