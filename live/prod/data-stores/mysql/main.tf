provider "aws" {
  region = "us-east-2"
  version = "~>3.0"
}

data "aws_kms_secrets" "rds" {
  secret {
    name    = "db_password"
    payload = "AQICAHh5oWAaeN4mTm/kNW5G1iA+zCMhVmqdSRCpo0eVIBHUywF0D/+TQyUib595QmvjWpX3AAAAZjBkBgkqhkiG9w0BBwagVzBVAgEAMFAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM4kfhNUDwOPwX6fwTAgEQgCN+H3dUKkXR7T2RMqemC6+ub4BL/TJP8zPt+TXSmVgR2M+KLQ=="
  }
}

resource "aws_db_instance" "prod" {
  identifier           = "prod-terraform-rds-db"
  skip_final_snapshot  = true
  multi_az             = true
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "prod_db"
  parameter_group_name = "default.mysql5.7"
  username             = "admin"
  password             = data.aws_kms_secrets.rds.plaintext.db_password
}

terraform {
  backend "s3" {
    bucket = "chysome-terraform-up-and-running"
    s3_key    = "prod/data-stores/mysql/terraform.tfstate"
    aws_region = "us-east-2"

    dynamodb_table = "chysome-terraform-up-and-running-lock"
    encrypt        = true
  }
}

