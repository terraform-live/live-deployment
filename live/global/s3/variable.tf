variable "s3_bucket_name" {
  description = "S3 bucket name for state file storage"
  type = string
}

variable "dynamodb_name" {
  description = "Dynamodb table name for state file lock"
  type = string
}