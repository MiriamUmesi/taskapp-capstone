# The VPC itself
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    # This tag is required by Kops to find the VPC
    "kubernetes.io/cluster/${var.project_name}" = "shared"
  }
}

# Internet Gateway — allows public subnets to reach the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Public subnets — one per AZ
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  # Resources in public subnets get a public IP automatically
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-${var.availability_zones[count.index]}"
    Environment = var.environment
    Type        = "public"
    # Required so Kubernetes knows it can put load balancers here
    "kubernetes.io/role/elb" = "1"
  }
}

# Private subnets — one per AZ, no public IPs
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-private-${var.availability_zones[count.index]}"
    Environment = var.environment
    Type        = "private"
    # Required so Kubernetes knows it can put internal load balancers here
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Elastic IPs for NAT Gateways — one per AZ
resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip-${var.availability_zones[count.index]}"
    Environment = var.environment
  }
}

# NAT Gateways — one per AZ, placed in public subnets
# Private nodes use these to reach the internet without being exposed
resource "aws_nat_gateway" "main" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.project_name}-nat-${var.availability_zones[count.index]}"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

# Route table for public subnets — sends all traffic to the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# Route tables for private subnets — one per AZ, each sends traffic to its own NAT
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name        = "${var.project_name}-private-rt-${var.availability_zones[count.index]}"
    Environment = var.environment
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate each private subnet with its own private route table
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
