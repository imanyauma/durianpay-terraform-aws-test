#VPC
resource "aws_vpc" "durianpay" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Durianpay Test"
  }
}

#Create Public Subnet
resource "aws_subnet" "public-subnet-1" {
    vpc_id  = aws_vpc.durianpay.id
    cidr_block = "192.168.0.0/24"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
    tags = {
      Name = "Public Subnet 1"
    }
}

#Create Private Subnet
resource "aws_subnet" "private-subnet-1" {
  vpc_id = aws_vpc.durianpay.id
  cidr_block = "192.168.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private Subnet 1"
  }
}


#Create Internet Gateway and attach to VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.durianpay.id
  tags = {
    Name = "IGW"
  }
}

# Create two Elastic IP for NAT Gateway
resource "aws_eip" "eip-1" {
  vpc = true
}

# Create two NAT Gateway for each AZ
resource "aws_nat_gateway" "nat-gw-1" {
  allocation_id = aws_eip.eip-1.id
  subnet_id = aws_subnet.public-subnet-1.id
  tags = {
    Name = "PrivateNAT"
  }
}

#Create Public Route Table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.durianpay.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

#Create Private Route Table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.durianpay.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw-1.id
  }
  tags = {
    Name = "Private Route Table"
  }
}

#Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public-route-table-1" {
  subnet_id = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

#Associate App and Database Subnets with App Route AZ1
resource "aws_route_table_association" "private-route-table-1" {
  subnet_id = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}

module "aws_ec2" {
  source = "./modules/ec2"
  asg_name = var.asg_name
  public-subnet-1 = aws_subnet.private-subnet-1.id
  vpc_id = aws_vpc.durianpay.id
}

module "cloudwatch_dashboard" {
  source                  = "./modules/cloudwatch"
  autoscaling_group_name  = module.aws_ec2.asg_name
}