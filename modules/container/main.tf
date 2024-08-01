# --- container/main.tf ---

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "bold-cd-acloud-${var.project}-${var.environment}-ecs-cluster"

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-ecs-cluster"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "bold-cd-acloud-${var.project}-${var.environment}-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-ecsTaskRole"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_iam_policy" "rds_policy" {
  name        = "bold-cd-acloud-${var.project}-${var.environment}-policy-rds"
  description = "Policy that allows access to RDS: Aurora"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": [
               "rds:CreateTable",
               "rds:UpdateTimeToLive",
               "rds:PutItem",
               "rds:DescribeTable",
               "rds:ListTables",
               "rds:DeleteItem",
               "rds:GetItem",
               "rds:Scan",
               "rds:Query",
               "rds:UpdateItem",
               "rds:UpdateTable"
           ],
           "Resource": "*"
       }
   ]
}
EOF
  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-policy-rds"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.rds_policy.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "bold-cd-acloud-${var.project}-${var.environment}-policy-ecs"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-policy-ecs"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ecs_sg" {
  name        = "bold-cd-acloud-${var.project}-${var.environment}-ecs-sg"
  vpc_id      = var.vpc_cidr
  description = "Security Group for Public Access"

  ingress {
    description      = "Security Group used to ECS Cluster"
    protocol         = "tcp"
    from_port        = var.ecs_container_port
    to_port          = var.ecs_container_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}