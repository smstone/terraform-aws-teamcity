resource "aws_alb" "alb" {
  internal           = var.alb_internal
  load_balancer_type = "application"
  subnets            = var.alb_internal ? var.private_subnets : var.public_subnets
  security_groups    = [aws_security_group.alb.id]

  tags = var.tags
}

resource "aws_lb_listener" "alb_listener_80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb_listener_443" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.alb_acm_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-3-2021-06"


  lifecycle {
    create_before_destroy = true
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  deregistration_delay = 60
  port                 = 8111
  protocol             = "HTTP"
  vpc_id               = var.vpc_id

  health_check {
    interval          = 30
    port              = 8111
    protocol          = "HTTP"
    healthy_threshold = 3
    path              = "/healthCheck/healthy"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}
