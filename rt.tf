//Creating route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "Premium Auto private RT"
  }
}

resource "aws_route_table_association" "private_association" {
  count = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat_eip" {
  count = 2
  vpc = true
  depends_on = [aws_internet_gateway.igw]
}

//Creating NAT
//TODO: chanage from private to public subnet
//rename ngw to nat_gatewayn
resource "aws_nat_gateway" "nat_gateway" {    
  allocation_id = aws_eip.nat_eip[count.index].id  
  count = length(var.public_subnet_cidrs)
  //subnet_id = element(aws_subnet.private_subnet[*].id, count.index)
  subnet_id = aws_subnet.public_subnet[count.index].id
  tags = {
    "Name" = "Premium Auto ngw"
  }
}

//Creating a route table and associating with igw
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.nginx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Premium Auto public RT"
  }
}

//Associating Public Subnets to the Route Table
resource "aws_route_table_association" "public_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nginx_vpc.id

  tags = {
    Name = "Premium Auto internet gateway"
  }
}

