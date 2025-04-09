resource "aws_security_group" "teamcity" {
  name        = "Teamcity instance security group"
  description = "Terraform security group"
  vpc_id      = var.vpc_id


  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    description = "Build Agent port"
    # tfsec:ignore:AWS008
    cidr_blocks = var.instance_cidr_allowlist
  }

  ingress {
    from_port       = 8111
    to_port         = 8111
    protocol        = "tcp"
    description     = "Ingress to port 8111"
    security_groups = flatten(var.instance_sg_allowlist, [aws_security_group.alb.id])
    # tfsec:ignore:AWS008
    cidr_blocks = var.instance_cidr_allowlist
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH to instance"
    # tfsec:ignore:AWS008
    cidr_blocks = var.instance_cidr_allowlist
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    description = "Allows traffic to self"
    self        = true
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # tfsec:ignore:AWS009
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
