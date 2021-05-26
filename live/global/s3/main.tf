provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name
  acl    = "private"
  tags = {
    Name        = "edl-east-privacera"
    Environment = "IMPL"
  }

  # Enable versioning so we can see the full revision history of our
  # state files

  versioning {
    enabled = true
  }
    lifecycle_rule {
      enabled = true
  }

    lifecycle {
      prevent_destroy = false
  }

  # Enable server-side encryption by default

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

