# Output the VPC ID so other modules can use it
# e.g ALB and ECS need to know which VPC to launch into
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

# Output all subnet IDs as a list
# e.g ALB needs at least 2 subnets, ECS needs to know where to run tasks
output "public_subnet_ids" {
  description = "Public subnet IDs"
  # [*] means get the ID from every subnet in the list
  value       = aws_subnet.public[*].id
}