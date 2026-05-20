# Output the ECS cluster ID
output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.this.id
}

# Output the ECS service name
output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.this.name
}