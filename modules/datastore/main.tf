resource "aws_security_group" "elasticache_sg" {
  name_prefix = "elasticache_sg_"
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id           = var.name
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_nodes
  security_group_ids   = [aws_security_group.elasticache_sg.id]
  parameter_group_name = "default.redis5.0.cluster.on"
}

resource "aws_iam_policy" "elasticache_policy" {
  name_prefix = "elasticache_policy_"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticache:Describe*",
          "elasticache:List*",
          "elasticache:CreateSnapshot",
          "elasticache:DeleteSnapshot"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "elasticache_role" {
  name_prefix = "elasticache_role_"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticache.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elasticache_attachment" {
  policy_arn = aws_iam_policy.elasticache_policy.arn
  role       = aws_iam_role.elasticache_role.name
}

resource "aws_elasticache_snapshot" "elasticache_snapshot" {
  snapshot_name        = "elasticache_snapshot"
  replication_group_id = aws_elasticache_cluster.elasticache_cluster.replication_group_id
  iam_role_arn         = aws_iam_role.elasticache_role.arn
}
