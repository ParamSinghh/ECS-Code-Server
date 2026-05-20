# Create the VPC - this is our private network on AWS
resource "aws_vpc" "this" {
  # The IP range for our network - 10.0.0.0/16 gives us 65,000 possible IPs
  cidr_block           = var.vpc_cidr
  # Allow resources inside the VPC to have DNS names like ec2-xxx.compute.amazonaws.com
  enable_dns_hostnames = true
  # Allow DNS to work inside the VPC
  enable_dns_support   = true

  tags = {
    # Name tag so we can identify it in the AWS console
    Name = "${var.project_name}-vpc"
  }
}

# Create public subnets - one in each availability zone
resource "aws_subnet" "public" {
  # Create 3 subnets (one per availability zone)
  count             = length(var.public_subnet_cidrs)
  # Put these subnets inside our VPC
  vpc_id            = aws_vpc.this.id
  # Each subnet gets its own IP range e.g 10.0.1.0/24, 10.0.2.0/24
  cidr_block        = var.public_subnet_cidrs[count.index]
  # Place each subnet in a different availability zone e.g eu-west-2a, 2b, 2c
  availability_zone = var.availability_zones[count.index]
  # Automatically give a public IP to anything launched in this subnet
  map_public_ip_on_launch = true

  tags = {
    # Name each subnet with a number e.g code-server-public-subnet-1
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# Create an internet gateway - this is the door between our VPC and the internet
resource "aws_internet_gateway" "this" {
  # Attach the internet gateway to our VPC
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create a route table - like a sat nav for network traffic
resource "aws_route_table" "public" {
  # Attach this route table to our VPC
  vpc_id = aws_vpc.this.id

  # Add a route that sends all traffic to the internet gateway
  route {
    # 0.0.0.0/0 means ALL traffic
    cidr_block = "0.0.0.0/0"
    # Send it to our internet gateway
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Link the route table to each subnet
# Without this the subnets wouldn't know to use the route table
resource "aws_route_table_association" "public" {
  # Do this for each subnet we created
  count          = length(aws_subnet.public)
  # Get the subnet ID for each one
  subnet_id      = aws_subnet.public[count.index].id
  # Link it to our route table
  route_table_id = aws_route_table.public.id
}