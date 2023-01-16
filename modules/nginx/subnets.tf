resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.premium_auto_vpc.id
  count = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.avail_zones[count.index]

  tags = {
    Name = "public Subnet ${count.index + 1}"
 }    
}
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.premium_auto_vpc.id
  count = length(var.private_subnet_cidrs)  
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.avail_zones[count.index]

  tags = {
    Name = "private Subnet ${count.index + 1}"
 }    
}

