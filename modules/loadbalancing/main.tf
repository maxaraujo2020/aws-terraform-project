resource "aws_security_group" "lb_sg" {
  name        = "bold-cd-acloud-${var.project}-${var.environment}-lb-sg"
  vpc_id      = var.vpc_cidr
  description = "Security Group for Public Access"

  ingress {
    description = "Security Group used to Application"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "loadbalancer" {
  name               = "bold-cd-acloud-${var.project}-${var.environment}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnets.*

  enable_deletion_protection = false

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-lb"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_alb_target_group" "targetgroup" {
  name        = "bold-cd-acloud-${var.project}-${var.environment}-tg"
  port        = var.tg_port
  protocol    = var.tg_protocol
  vpc_id      = var.vpc_cidr
  target_type = "ip"

  health_check {
    healthy_threshold   = var.lb_health_threshold
    interval            = var.lb_interval
    protocol            = var.listener_protocol
    timeout             = var.lb_timeout
    path                = var.lb_health_check_path
    unhealthy_threshold = var.lb_unhealth_threshold
  }

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-tg"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    target_group_arn = aws_alb_target_group.targetgroup.arn
    type             = "forward"
  }

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-http"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

#resource "aws_alb_listener" "https" {
#  load_balancer_arn = aws_lb.loadbalancer.id
#  port              = 443
#  protocol          = "HTTPS"

#  ssl_policy      = "ELBSecurityPolicy-2016-08"
#  certificate_arn = var.https_listeners

#  default_action {
#    target_group_arn = aws_alb_target_group.targetgroup.id
#    type             = "forward"
#  }

#  tags = {
#    Name        = "bold-cd-acloud-${var.lb_name}-${var.environment}-https"
#    Entity      = "Bold"
#    Unit        = "cd"
#    Team        = "ACloud"
#    Project     = "${var.project}"
#    Environment = "${var.environment}"
#    Region      = "${var.region}"
#    Repository  = "${var.repository}"
#  }
#}
