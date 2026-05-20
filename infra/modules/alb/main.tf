# Create a security group for the ALB
# This controls what traffic can reach the load balancer
resource "aws_security_group" "alb" {
  # Name the security group
  name        = "${var.project_name}-alb-sg"
  # Put it in our VPC
  vpc_id      = var.vpc_id

  # Allow HTTP traffic from anywhere on the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # 0.0.0.0/0 means anyone on the internet
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic from anywhere on the internet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  # ALB needs to forward traffic to ECS containers
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Create the Application Load Balancer
resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  # Internet-facing means it accepts traffic from the internet
  internal           = false
  # ALB handles HTTP/HTTPS traffic
  load_balancer_type = "application"
  # Use the security group we created above
  security_groups    = [aws_security_group.alb.id]
  # Launch the ALB across all our public subnets
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Create a target group - this is where the ALB forwards traffic to
# In our case it forwards to our ECS containers
resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-tg"
  # Forward traffic to port 8080 (code-server port)
  port        = 8080
  protocol    = "HTTP"
  # IP target type because ECS Fargate uses IP addresses not instances
  target_type = "ip"
  # Put it in our VPC
  vpc_id      = var.vpc_id

  # Health check - ALB pings this to make sure the container is healthy
  health_check {
    # Check the root path
    path                = "/"
    protocol            = "HTTP"
    # Consider healthy after 2 successful checks
    healthy_threshold   = 2
    # Consider unhealthy after 3 failed checks
    unhealthy_threshold = 3
    # Wait 30 seconds between checks
    interval            = 30
    # A 200 response means healthy
    matcher             = "200"
  }
}

# HTTP listener - listens on port 80 and redirects to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  # Redirect all HTTP traffic to HTTPS
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      # 301 is a permanent redirect
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener - listens on port 443 and forwards to target group
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  # Use our ACM certificate for SSL
  certificate_arn   = var.certificate_arn

  # Forward traffic to our target group (ECS containers)
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}