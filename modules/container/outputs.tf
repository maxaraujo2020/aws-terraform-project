# --- container/outputs.tf ---

output "container_port" {
  value = var.ecs_container_port
}

output "cluster" {
  value = aws_ecs_cluster.ecs_cluster.name
}