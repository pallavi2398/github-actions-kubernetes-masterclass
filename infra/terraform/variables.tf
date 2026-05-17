variable "aws_region" {
  description = "AWS region where the EC2 instance will be created"
  type        = string
  default     = "us-west-2"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "ec2_instance_name" {
  description = "Name prefix for the EC2 instance"
  type        = string
  default     = "terra-auto-server"
}

variable "ec2_instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 instance. Use an Ubuntu AMI for the selected AWS region."
  type        = string
  default     = "ami-0d76b909de1a0595d"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 8
}

variable "public_key_path" {
  description = "Path to the SSH public key used for the EC2 key pair"
  type        = string
  default     = "./terra-automate-key.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into the EC2 instance. For better security, use your public IP with /32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to access the application on HTTP port 80"
  type        = string
  default     = "0.0.0.0/0"
}
