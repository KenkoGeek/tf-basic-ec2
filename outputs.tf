output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_instance.id
}

output "instance_ip" {
  description = "IP address of the EC2 instance"
  value       = aws_instance.ec2_instance.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2_instance_sg.id
}
