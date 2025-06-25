# Create Application Load Balancer
resource "aws_lb" "serpent_alb" {
  name               = "serpent-surge-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.game_subnet.id,
    aws_subnet.game_subnet_2.id
                    ]

  tags = {
    Environment = "Development"
    Project     = "serpent-surge"
  }
}

# Create ALB Target Group
resource "aws_lb_target_group" "serpent_tg" {
  name     = "serpent-surge-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.serpent_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    timeout            = 5
    unhealthy_threshold = 2
  }
}

# Attach EC2 instances to target group
resource "aws_lb_target_group_attachment" "serpent_tg_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.serpent_tg.arn
  target_id        = aws_instance.serpent_surge[count.index].id
  port             = 80
}

# Create HTTPS listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.serpent_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.epooz_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.serpent_tg.arn
  }
}

# Create HTTP listener that redirects to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.serpent_alb.arn
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