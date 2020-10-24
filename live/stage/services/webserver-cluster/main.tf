provider "aws" {
  region = "us-east-2"
  version = "~>3.0"
}

terraform {
  backend "s3" {
    bucket = "chysome-terraform-up-and-running"
    s3_key    = "stage/services/webserver-cluster/terraform.tfstate"
    aws_region = "us-east-2"

    dynamodb_table = "chysome-terraform-up-and-running-lock"
    encrypt        = true
  }
}

module "webserver_cluster" {
  source = "git@github.com:terraform-live/modules.git//services/webserver-cluster?ref=master"

	cluster_name						= "webservers-stage"
	db_remote_state_bucket	= "chysome-terraform-up-and-running"
	db_remote_state_key			= "stage/data-stores/mysql/terraform.tfstate"
  ssh_key                 = "stage-ssh-key"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 2

  custom_tags = {
    Owner     = "delta-team"
    DeployedBy  = "terraform"   
  }
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id
  from_port         = 12345
  to_port           = 12345
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}