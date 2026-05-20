# Output the ALB ARN - ECS service needs this to register with the ALB
output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.this.arn
}

# Output the ALB DNS name - Route 53 needs this to point the domain at the ALB
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.this.dns_name
}

# Output the ALB zone ID - Route 53 needs this for the alias record
output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = aws_lb.this.zone_id
}

# Output the target group ARN - ECS service needs this to register containers
output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.this.arn
}

# Output the ALB security group ID - ECS security group needs this
output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}