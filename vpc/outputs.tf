output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_by_az" {
  value = { for obj in aws_subnet.public : obj.availability_zone => obj.id... }
}

output "private_app_subnets_by_az" {
  value = local.app_azs
}

output "private_db_subnets_by_az" {
  value = local.db_azs
}

output "public_subnets" {
  value = sort(values(aws_subnet.public)[*].id)
}

output "private_app_subnets" {
  value = sort(flatten(values(local.app_azs)))
}

output "private_db_subnets" {
  value = sort(flatten(values(local.db_azs)))
}