# Define our VPC
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "k8s-vpc-tag"
  }
}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "ap-southeast-1a"

  tags {
    Name = "k8s Public Subnet"
  }
}

# Define the private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "ap-southeast-1a"

  tags {
    Name = "k8s Private Subnet"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "k8s-igw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "k8s VPC IGW"
  }
}

# Define the route table
resource "aws_route_table" "k8s-public-define-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.k8s-igw.id}"
  }

  tags {
    Name = "k8s Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "k8s-public-rt" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.k8s-public-define-rt.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "k8s-public-sg" {
  name = "k8s-public-sg"
  description = "Allow incoming HTTP connections & SSH access"

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

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.default.id}"

  tags {
    Name = "k8s master SG"
  }
}

# Define the security group for private subnet
resource "aws_security_group" "k8s-private-sg"{
  name = "k8s-private-sg"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "k8s vpc"
  }
}

