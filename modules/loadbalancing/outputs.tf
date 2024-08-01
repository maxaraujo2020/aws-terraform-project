# --- loadbalancing/outputs.tf ---

output "alb_tg_arn" {
  value = aws_alb_target_group.targetgroup.arn
}