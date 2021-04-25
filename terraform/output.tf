output "lb" {
  value       = aws_lb.application-lb
  sensitive   = false
  description = "Output the Load Balancer"
}

output "eip" {
  value       = aws_eip.nat_eip.*
  sensitive   = false
  description = "Output the EIP"
}

output "public_subnets" {
  value       = aws_subnet.public_subnet.*
  sensitive   = false
  description = "Output the public subnets"
}

output "private_subnets" {
  value       = aws_subnet.private_subnet.*
  sensitive   = false
  description = "Output the private subnets"
}
