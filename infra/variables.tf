variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "code-server"
}

variable "domain_name" {
  description = "Your domain name"
  type        = string
  default     = "paramsingh.co.uk"
}

variable "container_image" {
  description = "ECR image URI"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}