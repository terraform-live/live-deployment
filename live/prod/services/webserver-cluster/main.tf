provider "aws" {
  region = "us-east-2"
  version = "~>3.0"
}

terraform {
  backend "s3" {
    bucket = "chysome-terraform-up-and-running"
    key    = "prod/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "chysome-terraform-up-and-running-lock"
    encrypt        = true
  }
}


module "webserver_cluster" {

  source = "../../../modules/services/webserver-cluster"

	cluster_name						= "webservers-prod"
	db_remote_state_bucket	= "chysome-terraform-up-and-running"
	db_remote_state_key			= "prod/data-stores/mysql/terraform.tfstate"
  ssh_key                 = "prod-up-and-running"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 4
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  
  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 4
  max_size = 10
  desired_capacity = 10
  recurrence = "00 11 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}
resource "aws_autoscaling_schedule" "scale_in-at-night" {
  
  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}
