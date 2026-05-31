output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "alb_sg_id" {
  description = "The ID of the ALB Security Group"
  value       = aws_security_group.alb.id
}

output "ec2_sg_id" {
  description = "The ID of the EC2 Security Group"
  value       = aws_security_group.ec2.id
}

output "redis_sg_id" {
  description = "The ID of the Redis Security Group"
  value       = aws_security_group.redis.id
}