resource "aws_security_group" "alb" {
  name        = "teamcity-alb-sg"
  vpc_id      = var.vpc_id
  description = "Protects ALB access"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "http access"
    # tfsec:ignore:AWS008
    cidr_blocks = var.alb_allowlist
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "SSL access"
    # tfsec:ignore:AWS008
    cidr_blocks = var.alb_allowlist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow outbound"
    # tfsec:ignore:AWS009
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
