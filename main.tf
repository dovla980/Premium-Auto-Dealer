terraform {
  backend "s3" {
    bucket = "s3-bucket-state"
    key = "global/s3/terraform.tfstate"
    region = "eu-west-3"
    encrypt = true
  }
}


provider "aws" {
  region = "eu-west-3"
}
//TODO: add s3 as a backend
//investigate how to revert broken state file on s3 bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "s3-bucket-state"
  lifecycle {
    prevent_destroy = true
  }
  
  
}
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
    
}
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


//TODO: rename VPC
resource "aws_vpc" "nginx_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Nginx VPC"
  }  
}

//Application Load Balancer
//TODO add listeners and target groups

resource "aws_lb" "app_lb" {
  name = "nginx-load-balancer"
  load_balancer_type = "application"
  security_groups = [aws_security_group.sg_lb.id]
  subnets = aws_subnet.public_subnet.*.id
  enable_cross_zone_load_balancing = true
  
}

resource "aws_lb_target_group" "group" {
  name = "terraform-alb-target"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.nginx_vpc.id

}
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.group.arn
    type = "forward"
  }
  tags = {
    "Name" = "HTTP Listener"
  }
}

resource "aws_launch_configuration" "nginx_config" {

  name = "nginx_config"
  image_id = "ami-0f15e0a4c8d3ee5fe"
  instance_type = "t2.micro"
  key_name = "ec2"
  security_groups = [aws_security_group.sg_lb.id]
    associate_public_ip_address = true
    user_data = <<EOF
                #!/bin/bash
            sudo yum update -y
            sudo amazon-linux-extras install nginx1 -y 
            sudo systemctl enable nginx
            sudo systemctl start nginx
                EOF
}

resource "aws_autoscaling_group" "asg_group" {
  name = "nginx_asg"
  min_size = 1
  desired_capacity = 1
  max_size = 2
  health_check_type = "ELB"
  

  launch_configuration = aws_launch_configuration.nginx_config.name
  vpc_zone_identifier = ["${aws_subnet.private_subnet.0.id}"]

}

