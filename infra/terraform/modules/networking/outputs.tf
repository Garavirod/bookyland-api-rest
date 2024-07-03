output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets_id" {
  value = aws_subnet.bookyland_private_subnets[*].id
}

output "public_subnets_id" {
  value = aws_subnet.bookyland_public_subnets[*].id
}
