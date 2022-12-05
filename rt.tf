//Creating route table for private subnets
resource "aws_route_table" "rt_ngw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "Premium Auto private RT"
  }
}

resource "aws_route_table_association" "rt_asso_ngw" {
  count = length(var.private_subnet_cidrs)
  subnet_id = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.rt_ngw.id
}

//Creating NAT
resource "aws_nat_gateway" "ngw" {  
  connectivity_type = "private"
  count = length(var.private_subnet_cidrs)
  subnet_id = element(aws_subnet.private_subnet[*].id, count.index)

  tags = {
    "Name" = "Premium Auto ngw"
  }
}

//Creating a route table and associating with igw
resource "aws_route_table" "rt_igw" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Premium Auto public RT"
  }
}

//Associating Public Subnets to the Route Table
resource "aws_route_table_association" "rt_asso" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.rt_igw.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "Premium Auto igw"
  }
}

