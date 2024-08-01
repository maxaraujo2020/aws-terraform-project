resource "aws_ecr_repository" "ecr_repository" {
  name                 = "bold-cd-acloud-${var.project}-${var.environment}-ecr"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-ecr"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle" {
  repository = aws_ecr_repository.ecr_repository.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}