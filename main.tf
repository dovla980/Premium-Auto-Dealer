provider "aws" {
  region = "eu-west-3"
}

resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Premium Auto VPC"
  }  
}

//Application Load Balancer
resource "aws_lb" "alb" {
  name = "premium-auto-lb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.sg-lb.id]
  subnets = aws_subnet.public_subnet.*.id
  enable_cross_zone_load_balancing = true
}

resource "aws_launch_configuration" "cfg" {

  name = "premium_cfg"
  image_id = "ami-0f15e0a4c8d3ee5fe"
    instance_type = "t2.micro"
    key_name = "ec2"
  security_groups = [aws_security_group.sg-lb.id]
    associate_public_ip_address = true
    user_data = <<EOF
                #!/bin/bash
            sudo yum update -y
            sudo amazon-linux-extras install nginx1 -y 
            sudo systemctl enable nginx
            sudo systemctl start nginx
                EOF
}

resource "aws_autoscaling_group" "asg" {
  name = "premium_asg"
  min_size = 1
  desired_capacity = 1
  max_size = 2
  health_check_type = "ELB"
  

  launch_configuration = aws_launch_configuration.cfg.name
  vpc_zone_identifier = ["${aws_subnet.public_subnet.0.id}"]

}

