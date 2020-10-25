provider "aws" {
  region = "us-east-2"
  version = "~>3.0"
}
 
module "webserver_cluster" {

  source = "git@github.com:terraform-live/modules.git//services/webserver-cluster?ref=master"

	cluster_name						= "webservers-prod"
	db_remote_state_bucket	= "chysome-terraform-up-and-running"
	db_remote_state_key			= "prod/data-stores/mysql/terraform.tfstate"
  ssh_key                 = "prod-up-and-running"
  s3_backend              = "prod/services/webserver-cluster/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 4
  enable_autoscaling      = true
  enable_new_user_data    = false
  give_neo_cloudwatch_full_access = true

  custom_tags = {
    Owner     = "delta-team"
    DeployedBy  = "terraform"   
  }
}


