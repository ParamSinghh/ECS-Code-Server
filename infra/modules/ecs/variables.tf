# Project name for naming resources
variable "project_name" {
  description = "Project name"
  type        = string
}

# AWS region for CloudWatch logs
variable "aws_region" {
  description = "AWS region"
  type        = string
}

# VPC ID from the VPC module
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# Subnet IDs from the VPC module
variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

# ALB security group ID from the ALB module
# ECS only accepts traffic from the ALB
variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}

# Target group ARN from the ALB module
# ECS registers containers with this target group
variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

# ALB listener ARN - ECS waits for this before starting
variable "alb_listener_arn" {
  description = "ALB listener ARN"
  type        = string
}

# The ECR image URI to run
variable "container_image" {
  description = "Container image URI"
  type        = string
}

# CPU units for the task - 256 is 0.25 vCPU (cheapest)
variable "task_cpu" {
  description = "Task CPU units"
  type        = string
  default     = "256"
}

# Memory for the task - 512 is 0.5GB (cheapest)
variable "task_memory" {
  description = "Task memory in MB"
  type        = string
  default     = "512"
}

# How many containers to run
variable "desired_count" {
  description = "Number of containers to run"
  type        = number
  default     = 1
}