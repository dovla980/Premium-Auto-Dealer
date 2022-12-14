resource "aws_security_group" "sg_lb" {
  vpc_id = aws_vpc.premium_auto_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "Load Balancer Security group"
  }
}

resource "aws_security_group" "sg_ec2" {
  vpc_id = aws_vpc.premium_auto_vpc.id
  
  ingress {
    from_port = 80    
    to_port = 80    
    protocol = "tcp"
    security_groups = [
      aws_security_group.sg_lb.id
    ]    
  }
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "EC2 Security group"
  }
}
