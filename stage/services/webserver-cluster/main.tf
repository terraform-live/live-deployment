provider "aws" {
  region = "us-east-2"
  required_version = ">0.12 < 0.13"
}


module "webserver_cluster" {

  source = "../../../modules/services/webserver-cluster"

	cluster_name						= "webservers-stage"
	db_remote_state_bucket	= "chysome-terraform-up-and-running"
	db_remote_state_key			= "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 2
}

