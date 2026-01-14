# ------------------------------
# VPC
# ------------------------------
resource "aws_vpc" "k8s" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "k8s-vpc"
  }
}

# ------------------------------
# Public Subnets
# ------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_azs)
  vpc_id                  = aws_vpc.k8s.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.public_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-public-${count.index + 1}"
  }
}

# ------------------------------
# Private Subnets
# ------------------------------
resource "aws_subnet" "private" {
  count             = length(var.public_azs)
  vpc_id            = aws_vpc.k8s.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.public_azs[count.index]

  tags = {
    Name = "k8s-private-${count.index + 1}"
  }
}

# ------------------------------
# Internet Gateway
# ------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8s.id

  tags = {
    Name = "k8s-igw"
  }
}

# ------------------------------
# Public Route Table
# ------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.k8s.id

  tags = {
    Name = "k8s-public-rt"
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Route Table with Public Subnets
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# ------------------------------
# Security Groups
# ------------------------------

# Master Security Group
resource "aws_security_group" "master_sg" {
  vpc_id = aws_vpc.k8s.id
  name   = "k8s-master-sg"

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Kubernetes API access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-master-sg"
  }
}

# Worker Security Group
resource "aws_security_group" "worker_sg" {
  vpc_id = aws_vpc.k8s.id
  name   = "k8s-worker-sg"

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Kubelet API"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-worker-sg"
  }
}
