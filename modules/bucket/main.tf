resource "aws_s3_bucket" "bucket_s3" {
  bucket = "bold-cd-acloud-${var.project}-${var.environment}-s3"

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-s3"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_s3_bucket_acl" "bucket_s3_permission" {
  bucket = aws_s3_bucket.bucket_s3.id
  acl    = "private"
}