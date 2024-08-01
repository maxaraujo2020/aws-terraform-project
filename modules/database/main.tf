# --- database/main.tf ---

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = length(var.private_sn_count)
  identifier         = "bold-cd-acloud-${var.project}-${var.environment}-rds-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.cluster.id
  instance_class     = var.db_instance_class
  engine             = var.db_engine
  engine_version     = var.db_engine_version

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-rds-instance"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier      = "bold-cd-acloud-${var.project}-${var.environment}-rds"
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  database_name           = var.db_name
  db_subnet_group_name    = var.db_subnet_group_name[0]
  master_username         = var.db_user
  master_password         = var.db_password
  backup_retention_period = var.db_backup_retention_period
  preferred_backup_window = var.db_preferred_backup_window
  skip_final_snapshot     = var.db_skip_final_snapshot

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-rds"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}
