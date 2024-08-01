# --- root/main.tf ---

module "networking" {
  source           = "./modules/networking"
  vpc_cidr         = local.vpc_cidr
  access_ip        = var.access_ip
  security_groups  = local.security_groups
  public_sn_count  = 3
  private_sn_count = 3
  max_subnets      = 6
  project          = "repsol"
  region           = "eu-west-1"
  repository       = "https://bitbucket.org/maraujoda/repsol-repo/src/main/"
  environment      = "prd"
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  db_subnet_group  = true
}

module "database" {
  source                     = "./modules/database"
  private_sn_count           = module.networking.private_subnets
  db_environment             = module.networking.env
  db_engine                  = "aurora-mysql"
  db_engine_version          = "5.7"
  db_instance_class          = "db.r6g.large"
  db_name                    = var.db_name
  db_user                    = var.db_user
  db_password                = var.db_password
  db_subnet_group_name       = module.networking.db_subnet_group_name
  db_backup_retention_period = 7
  db_preferred_backup_window = "02:00-05:00"
  db_skip_final_snapshot     = true
  project                    = module.networking.project_name
  region                     = module.networking.region
  repository                 = module.networking.repository
  environment                = module.networking.env
}

module "container" {
  source              = "./modules/container"
  vpc_cidr            = module.networking.vpc_id
  ecs_container_image = "nginxdemos/hello"
  ecs_container_port  = "80"
  alb_tg_arn          = module.loadbalancing.alb_tg_arn
  ecs_subnets         = module.networking.private_subnets
  project             = module.networking.project_name
  region              = module.networking.region
  repository          = module.networking.repository
  environment         = module.networking.env
}

module "loadbalancing" {
  source                = "./modules/loadbalancing"
  public_sg             = module.networking.public_sg
  public_subnets        = module.networking.public_subnets
  vpc_cidr              = module.networking.vpc_id
  ecs_cluster_name      = module.container.cluster
  tg_port               = 80
  tg_protocol           = "HTTP"
  vpc_id                = module.networking.vpc_id
  lb_health_threshold   = 2
  lb_unhealth_threshold = 2
  lb_timeout            = 3
  lb_interval           = 30
  lb_health_check_path  = "/"
  listener_port         = 80
  listener_protocol     = "HTTP"
  project               = module.networking.project_name
  region                = module.networking.region
  repository            = module.networking.repository
  environment           = module.networking.env
}

# module "datastore" {
#   source             	= "./modules/datastore"
#   node_count         	= 1
#   node_type          	= "cache.m3.medium"
#   availability_zones = ["us-east-1a", "us-east-1b"]
#   project          = module.networking.project_name
#   region           = module.networking.region
#   repository       = module.networking.repository
#   environment      = module.networking.env
# }

module "repository" {
  source      = "./modules/repository"
  project     = module.networking.project_name
  region      = module.networking.region
  repository  = module.networking.repository
  environment = module.networking.env
}

module "bucket" {
  source      = "./modules/bucket"
  project     = module.networking.project_name
  region      = module.networking.region
  repository  = module.networking.repository
  environment = module.networking.env
}