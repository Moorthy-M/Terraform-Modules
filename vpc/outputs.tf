output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_by_az" {
  value = { for obj in aws_subnet.public : obj.availability_zone => obj.id... }
}

output "private_app_subnets_by_az" {
  value = { for id, obj in local.app_subnets : aws_subnet.private[id].availability_zone => aws_subnet.private[id].id... }
}

output "private_db_subnets_by_az" {
  value = { for id, obj in local.db_subnets : aws_subnet.private[id].availability_zone => aws_subnet.private[id].id... }
}

output "public_subnets" {
  value = sort(values(aws_subnet.public)[*].id)
}

output "private_app_subnets" {
  value = sort([for id, obj in local.app_subnets : aws_subnet.private[id].id])
}

output "private_db_subnets" {
  value = sort([for id, obj in local.db_subnets : aws_subnet.private[id].id])
}