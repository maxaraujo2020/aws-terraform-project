variable "ecs_container_image" {}
variable "ecs_subnets" {}
variable "ecs_container_port" {
  type = number
}
variable "project" {}
variable "region" {}
variable "repository" {}
variable "environment" {}
variable "vpc_cidr" {}
variable "alb_tg_arn" {}