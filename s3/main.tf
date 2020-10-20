provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "chysome-terraform-up-and-running"

  # Enable versioning so we can see the full revision history of our
  # state files

  versioning {
    enabled = true
  }
    lifecycle_rule {
      enabled = true
  }

    lifecycle {
      prevent_destroy = true
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
  name         = "chysome-terraform-up-and-running-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

output "s3_bucket_arn" {
        description     = "The ARN of the s3 bucket"
        value           = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
        description     = "The name of the DynamoDB"
        value           = aws_dynamodb_table.terraform_locks.name
}

