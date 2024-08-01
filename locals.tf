# --- root/locals.tf ---
locals {
  vpc_cidr = "192.168.0.0/20"
}

locals {
  security_groups = {
    public = {
      name        = "bold-cd-acloud-${module.networking.project_name}-${module.networking.env}-alb-sg"
      description = "Security Group for Public Access"
      ingress = {
        http = {
          description = "Security Group used to Application"
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    rds = {
      name        = "bold-cd-acloud-${module.networking.project_name}-${module.networking.env}-rds-sg"
      description = "Security Group for RDS Aurora Access"
      ingress = {
        ssh = {
          description = "Security Group used to RDS Aurora Access"
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
  }
}