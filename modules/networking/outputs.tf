# --- networking/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.vpc_network.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.database_subnetgroup.*.name
}

output "db_subnet_group_id" {
  value = aws_db_subnet_group.database_subnetgroup.*.id
}

output "db_security_group" {
  value = [aws_security_group.security_group["rds"].id]
}

output "public_sg" {
  value = aws_security_group.security_group["public"].id
}

output "public_subnets" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}

output "project_name" {
  value = aws_vpc.vpc_network.tags.Project
}

output "env" {
  value = aws_vpc.vpc_network.tags.Environment
}

output "region" {
  value = aws_vpc.vpc_network.tags.Region
}

output "repository" {
  value = aws_vpc.vpc_network.tags.Repository
}
