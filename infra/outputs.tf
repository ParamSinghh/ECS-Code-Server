# Output the live URL
output "app_url" {
  description = "Live app URL"
  value       = "https://tm.${var.domain_name}"
}

# Output the ALB DNS name
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

# Output the ECR repository URL
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}