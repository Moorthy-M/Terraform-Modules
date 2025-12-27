locals {
  app_azs = { for id, obj in var.private_subnets : obj.availability_zone => id... if lower(obj.tier) == "app"}
  db_azs = { for id, obj in var.private_subnets : obj.availability_zone => id... if lower(obj.tier) == "db"}
  
  nat_azs = { 
    for id, obj in var.public_subnets : obj.availability_zone => id 
    if obj.nat && contains(keys(local.app_azs), obj.availability_zone)
  } 

  app_subnets = {for id, obj in var.private_subnets : id => obj.availability_zone if lower(obj.tier) == "app"}
  db_subnets = {for id, obj in var.private_subnets : id => obj.availability_zone if lower(obj.tier) == "db"}
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(var.tags, 
  {
    Name = "VPC-Main"
  })
}

resource "aws_subnet" "public" {
    for_each = var.public_subnets

  vpc_id = aws_vpc.main.id
  cidr_block = each.value.cidr_block
  map_public_ip_on_launch = true
  availability_zone = each.value.availability_zone

  tags = merge(var.tags, 
  {
    Name = "Public-${each.key}-Subnet"
  })
}

resource "aws_subnet" "private" {
    for_each = var.private_subnets

  vpc_id = aws_vpc.main.id
cidr_block = each.value.cidr_block
  map_public_ip_on_launch = false
  availability_zone = each.value.availability_zone

  tags = merge(var.tags, 
  {
    Name = "Private-${each.key}-Subnet"
    Tier = "${each.value.tier}"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, 
  {
    Name = "IGW-Main"
  })
}

resource "aws_eip" "eip" {
    for_each = var.enable_nat ? local.nat_azs : {}
  domain = "vpc"
  depends_on = [ aws_internet_gateway.igw ]

  /* lifecycle {
    precondition {
      condition = var.enable_nat == false || length(setsubtract(toset(keys(local.app_azs)), toset(keys(local.nat_azs)))) == 0
      error_message = "Each AZ containing app subnets must have exactly one NAT-enabled public subnet in the same AZ."
    }
  } */

  tags = merge(var.tags,
  {
    Name = "EIP-${each.key}"
  })
}

resource "aws_nat_gateway" "nat" {
  for_each = var.enable_nat ? local.nat_azs : {}
  allocation_id = aws_eip.eip[each.key].id
  subnet_id = aws_subnet.public[each.value].id

  depends_on = [ aws_eip.eip ]
  
  /* lifecycle {
    precondition {
    condition = alltrue([ for az in keys(local.nat_azs) : contains(keys(aws_eip.eip), az)])
    error_message = "NAT creation reqiures one EIP per AZ"
    }
  } */

  tags = merge(var.tags,
  {
    Name = "NAT-${each.key}"
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags,
  {
    Name = "RT-Public"
  })
}

resource "aws_route_table" "private_rt_app" {
    for_each = local.app_azs 

  vpc_id = aws_vpc.main.id

  tags = merge(var.tags,
  {
    Name = "RT-Private-App-${each.key}"
  })
}

resource "aws_route_table" "private_rt_db" {
    for_each = local.db_azs 
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags,
  {
    Name = "RT_Private-DB-${each.key}"
  })
}

resource "aws_route" "igw_route" {
  route_table_id = aws_route_table.public_rt.id
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "nat_route" {
    for_each = var.enable_nat ? local.app_azs : {}

  route_table_id = aws_route_table.private_rt_app[each.key].id
  nat_gateway_id = aws_nat_gateway.nat[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [ aws_nat_gateway.nat ]
}

resource "aws_route_table_association" "igw_route_association" {
    for_each = aws_subnet.public
  route_table_id = aws_route_table.public_rt.id
  subnet_id = each.value.id
}

resource "aws_route_table_association" "app_route_association" {
  for_each = local.app_subnets

  subnet_id = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private_rt_app[each.value].id
}

resource "aws_route_table_association" "db_route_association" {
  for_each = local.db_subnets

  subnet_id = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private_rt_db[each.value].id
}

# DB subnets intentionally have no internet route.
# Access via VPC endpoints or bastion only.

resource "aws_cloudwatch_log_group" "cloudwatch_log" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name = "/vpc/flow-logs"
  retention_in_days = 30
  tags = merge(var.tags,
  {
    Name = "Cloudwatch-Log-Group"
  })
}

resource "aws_flow_log" "flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  vpc_id = aws_vpc.main.id
  iam_role_arn = var.vpc_role_arn

  log_destination = aws_cloudwatch_log_group.cloudwatch_log[0].arn
  log_destination_type = "cloud-watch-logs"

  max_aggregation_interval = 60
  traffic_type = "REJECT"

  tags = merge(var.tags,
  {
    Name = "VPC-Flow-Logs"
  })
}