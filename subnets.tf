//Creating public and private subnets
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.test-vpc.id
  count = length(var.public_subnet_cidrs)
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
 }    
}
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.test-vpc.id
  count = length(var.private_subnet_cidrs)
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
 }    
}