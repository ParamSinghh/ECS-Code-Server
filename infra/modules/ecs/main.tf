# Create the ECS cluster - this is where all containers run
resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# IAM role that allows ECS to manage tasks on your behalf
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

  # This policy allows ECS to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          # Only ECS tasks can use this role
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AWS managed policy to the execution role
# This gives ECS permission to pull images from ECR and write logs
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  # AWS managed policy that covers ECR pull and CloudWatch logs
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Security group for ECS tasks
# Controls what traffic can reach our containers
resource "aws_security_group" "ecs_tasks" {
  name   = "${var.project_name}-ecs-sg"
  vpc_id = var.vpc_id

  # Only allow traffic from the ALB security group on port 8080
  # Containers should NOT be directly accessible from the internet
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    # Only accept traffic coming from the ALB
    security_groups = [var.alb_security_group_id]
  }

  # Allow all outbound traffic
  # Containers need to pull updates, talk to AWS services etc
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}

# Task definition - tells ECS how to run our container
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-task"
  # Fargate means AWS manages the servers
  requires_compatibilities = ["FARGATE"]
  # awsvpc gives each task its own network interface
  network_mode             = "awsvpc"
  # Minimum Fargate size to keep costs low
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  # The role that allows ECS to pull from ECR
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  # Container definition - describes our actual container
  container_definitions = jsonencode([
    {
      # Name of the container
      name  = var.project_name
      # The ECR image to run
      image = var.container_image
      # Mark as essential - if this container stops, the task stops
      essential = true

      # Port mapping - expose port 8080
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      # CloudWatch logs configuration
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          # Create a log group named after our project
          awslogs-group         = "/ecs/${var.project_name}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# CloudWatch log group for ECS logs
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.project_name}"
  # Keep logs for 7 days to minimise costs
  retention_in_days = 7
}

# ECS Service - keeps our container running and connects it to the ALB
resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-service"
  # Which cluster to run in
  cluster         = aws_ecs_cluster.this.id
  # Which task definition to use
  task_definition = aws_ecs_task_definition.this.arn
  # Run 1 container at a time
  desired_count   = var.desired_count
  # Use Fargate - no servers to manage
  launch_type     = "FARGATE"

  # Network configuration for the containers
  network_configuration {
    # Which subnets to run containers in
    subnets          = var.public_subnet_ids
    # Use our ECS security group
    security_groups  = [aws_security_group.ecs_tasks.id]
    # Give containers a public IP so they can reach ECR
    assign_public_ip = true
  }

  # Connect this service to the ALB
  load_balancer {
    # Which target group to register containers with
    target_group_arn = var.target_group_arn
    # The container name and port to forward traffic to
    container_name   = var.project_name
    container_port   = 8080
  }

  # Wait for the ALB target group to exist before creating the service
  depends_on = [var.alb_listener_arn]
}