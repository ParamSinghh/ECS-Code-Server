# Project name for naming resources
variable "project_name" {
  description = "Project name"
  type        = string
}

# VPC ID from the VPC module output
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# Subnet IDs from the VPC module output
variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

# ACM certificate ARN from the ACM module output
variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}