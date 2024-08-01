# --- networking/main.tf ---

## Define what AZ will be used in the Subnets
data "aws_availability_zones" "available" {}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

## Create the Repsol infrastructure - VPC
resource "aws_vpc" "vpc_network" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-vpc"
    Entity      = "bold"
    Unit        = "cd"
    Team        = "acloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

## Creating Public Subnets
resource "aws_subnet" "public_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.vpc_network.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "bold-cd-acloud-${var.project}-public-${var.environment}-snet"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

## Creating Private Subnets
resource "aws_subnet" "private_subnet" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.vpc_network.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name        = "bold-cd-acloud-${var.project}-private-${var.environment}-snet"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

## Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc_network.id

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-igw"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

## Creating NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.private_sn_count
  allocation_id = aws_eip.elastic_ip.*.id[count.index]
  subnet_id     = aws_subnet.public_subnet.*.id[count.index]
  depends_on    = [aws_internet_gateway.internet_gateway]

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-ngw"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

## Grant the VPC internet access on its main route table - Public Route
resource "aws_route" "public_route" {
  route_table_id         = aws_vpc.vpc_network.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name        = "bold-cd-acloud-${var.project}-public-${var.environment}-rt"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_route_table_association" "route_table_public_association" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.route_table_public.id
}

## Grant the VPC internet access on its main route table - Private Route
resource "aws_route" "private_route" {
  count                  = var.private_sn_count
  route_table_id         = aws_route_table.route_table_private.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.*.id[count.index]
}

resource "aws_route_table" "route_table_private" {
  count  = var.private_sn_count
  vpc_id = aws_vpc.vpc_network.id

  tags = {
    Name        = "bold-cd-acloud-${var.project}-private-${var.environment}-rt"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

resource "aws_route_table_association" "route_table_private_association" {
  count          = var.private_sn_count
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.route_table_private.*.id[count.index]
}

## Ensures all Private Subnets have elastic ips
resource "aws_eip" "elastic_ip" {
  count = var.private_sn_count
  vpc   = true

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-eip"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}

## Define security groups
resource "aws_security_group" "security_group" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc_network.id
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # for ALL
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Configuring Subnet to Database.
resource "aws_db_subnet_group" "database_subnetgroup" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "bold-cd-acloud-${var.project}-${var.environment}-rds-sn"
  subnet_ids = aws_subnet.private_subnet.*.id

  tags = {
    Name        = "bold-cd-acloud-${var.project}-${var.environment}-rds-sn"
    Entity      = "Bold"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}