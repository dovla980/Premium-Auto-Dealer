resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.premium_auto_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }
  tags = {
    Name = "Private route table ${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_association" {
  count = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private[count.index].id 
}

resource "aws_eip" "nat_eip" {
  count = length(var.public_subnet_cidrs)
  vpc = true  
}

resource "aws_nat_gateway" "nat_gateway" {    
  allocation_id = aws_eip.nat_eip[count.index].id  
  count = length(aws_subnet.public_subnet)  
  subnet_id = aws_subnet.public_subnet[count.index].id
  tags = {
    Name = "Nginx nat gateway ${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.premium_auto_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.resource_tags["public_rt"]
  }
}

resource "aws_route_table_association" "public_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id  
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.premium_auto_vpc.id

  tags = {
    Name = var.resource_tags["igw"]
  }
}

