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

resource "aws_vpc" "premium_auto_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Premium Auto VPC"
  }  
}

resource "aws_lb" "app_lb" {
  name = "nginx-load-balancer"
  load_balancer_type = "application"
  security_groups = [aws_security_group.sg_lb.id]
  subnets = aws_subnet.public_subnet.*.id
  enable_cross_zone_load_balancing = true  
}

resource "aws_lb_target_group" "nginx" {
  name = "nginx-alb-target"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.premium_auto_vpc.id
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.nginx.arn
    type = "forward"
  }
  tags = {
    "Name" = "HTTP Listener"
  }
}

resource "aws_launch_configuration" "nginx_config" {
  name = "nginx_config"
  image_id = "ami-0f15e0a4c8d3ee5fe"
  instance_type = "t3.micro"
  key_name = "ec2"
  security_groups = [aws_security_group.sg_ec2.id]    
    user_data = <<EOF
                #!/bin/bash
            sudo yum update -y
            sudo amazon-linux-extras install nginx1 -y 
            sudo systemctl enable nginx
            sudo systemctl start nginx
                EOF
}

resource "aws_autoscaling_group" "nginx" {
  name = "nginx_asg"
  min_size = 1
  desired_capacity = 1
  max_size = 2
  health_check_type = "ELB"
  target_group_arns = ["${aws_lb_target_group.nginx.arn}"]
  depends_on = [aws_lb.app_lb]

  launch_configuration = aws_launch_configuration.nginx_config.name
  vpc_zone_identifier = ["${aws_subnet.private_subnet.0.id}"]
}

