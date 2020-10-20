############### terraform version in use #############################
terraform {
  required_version = ">= 0.12, < 0.13"
}

############ Terraform Backend for State files ###################

terraform {
  backend "s3" {
    bucket = "chysome-terraform-up-and-running"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "chysome-terraform-up-and-running-lock"
    encrypt        = true
  }
}

##################### Remote State #####################

data "terraform_remote_state" "db" {
	backend "s3"
	config = {
		bucket = "chysome-terraform-up-and-running"
		key    = "stage/data-stores/mysql/terraform.tfstate"
		region = "us-east-2"
	}
}
   

##################### Initialize provider ###########################
provider "aws" {
    version = "~> 2.0"
    region = "us-east-2"
}

################### Define data sources here #######################

data "aws_vpc" "default" {
     default = true
}

data "aws_subnet_ids" "default" {
     vpc_id = data.aws_vpc.default.id
}
 
################### Instance security Group ########################

resource "aws_security_group" "instance" {
  name	         = "terraform-example-instance"

  ingress {
	from_port      = var.server_port
	to_port	       = var.server_port
	protocol       = "tcp"
	cidr_blocks    = ["0.0.0.0/0"]
    }

}

################### Configure Autoscaling Group #####################

resource "aws_launch_configuration" "example" {
	image_id 				= "ami-0c55b159cbfafe1f0"
	instance_type		= "t2.micro"
	security_groups	= [aws_security_group.instance.id]

	user_data = <<EOF
	#!/bin/bash
	echo "Hello, World" >> index.html
	echo "${data.terraform_remote_state.db.outputs.address}" >> index.html
	echo "${data.terraform_remote_state.db.outputs.port}" >> index.html
	nohup busybox httpd -f -p ${var.server_port} &
	EOF
	lifecycle {
	   create_before_destroy = true
        }
}

resource "aws_autoscaling_group" "example" {
	launch_configuration = aws_launch_configuration.example.name	
	vpc_zone_identifier  = data.aws_subnet_ids.default.ids
      
	target_group_arns = [aws_lb_target_group.asg.arn]
	health_check_type = "ELB"

        min_size = 2
	max_size = 4

	tag {
	   key = "Name"
           value = "terraform-asg-example"
           propagate_at_launch = true
	}
}

################### Configure Application Load Balancer ####################

resource "aws_lb" "example" {
	name = "terraform-asg-example"
	load_balancer_type = "application"
	subnets		   = data.aws_subnet_ids.default.ids
	security_groups	   = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.example.arn
	port		  = 80
	protocol	  = "HTTP"

	default_action {
	    type	= "fixed-response"

	    fixed_response {
		content_type = "text/plain"
		message_body = "404: Not found"
		status_code  = 404
            }
        }
}    

resource "aws_lb_listener_rule" "asg" {
	listener_arn = aws_lb_listener.http.arn
	priority     = 100

	condition {
	   path_pattern {
             values   = ["*"]
           }
	}

	action {
           type	     = "forward"
	   target_group_arn = aws_lb_target_group.asg.arn
        }
}

resource "aws_lb_target_group" "asg" {
	name = "terraform-asg-example"
	port = var.server_port
	protocol = "HTTP"
	vpc_id	 = data.aws_vpc.default.id

	health_check {
		path	 =	"/"
		protocol = "HTTP"
		matcher  = "200"
		interval = 15
		timeout	 = 3
		healthy_threshold   = 2
		unhealthy_threshold = 2
	}
}
resource "aws_security_group" "alb" {
    name    = "terraform-example-alb"
		
	ingress {
		from_port = 80
		to_port   = 80
		protocol  = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port   = 0
		protocol  = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

