output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_linux.id
}

output "instance_ip" {
  description = "IP address of the EC2 instance"
  value       = aws_instance.ec2_linux.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2_linux_sg.id
}
