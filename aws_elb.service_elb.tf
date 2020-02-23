resource "aws_elb" "service_elb" {
  subnets         = var.public_subnets
  security_groups = [aws_security_group.elb.id]
  instances       = [aws_instance.teamcity.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl_cert_arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/login.html"
    interval            = 30
  }

  tags = var.common_tags
}
