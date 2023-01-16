provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "premium_auto_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = merge(
    var.tags,  
    {
      Name = "Premium Auto VPC"
    },
  )  
}

resource "aws_lb" "app_lb" {
  name = "${var.application_name}-load-balancer"
  load_balancer_type = "application"
  security_groups = [aws_security_group.app_lb.id]
  subnets = aws_subnet.public_subnet.*.id
  enable_cross_zone_load_balancing = true  

  access_logs {
    bucket = "${var.application_name}-app-lb-access-logs"
    prefix = "alb"
    enabled = true
  }  
}

resource "aws_lb_target_group" "nginx" {
  name = "${var.application_name}-alb-target"
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
  tags = merge(
    var.tags,  
    {
      Name = "HTTP Listener"
    },
  )  
}

resource "aws_launch_configuration" "nginx_config" {
  name = "${var.application_name}_config"
  image_id = "ami-0f15e0a4c8d3ee5fe"
  instance_type = var.instance_type
  key_name = "ec2"
  security_groups = [aws_security_group.nginx_ec2.id]    
    user_data = <<EOF
                #!/bin/bash
            sudo yum update -y
            sudo amazon-linux-extras install nginx1 -y 
            sudo systemctl enable nginx
            sudo systemctl start nginx
                EOF
}

resource "aws_autoscaling_group" "nginx" {
  name = "${var.application_name}_asg"
  min_size = 1
  desired_capacity = 1
  max_size = 2
  health_check_type = "ELB"
  target_group_arns = ["${aws_lb_target_group.nginx.arn}"]
  depends_on = [aws_lb.app_lb]

  launch_configuration = aws_launch_configuration.nginx_config.name
  vpc_zone_identifier = ["${aws_subnet.private_subnet.0.id}"]
}

