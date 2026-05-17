output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server[*].public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server[*].public_dns
}

output "ssh_user" {
  description = "Default SSH user for Ubuntu AMIs"
  value       = "ubuntu"
}
