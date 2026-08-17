variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Jenkins will be deployed"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for Jenkins"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the Jenkins EC2 instance"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR allowed to access SSH"
  type        = string
  default     = "0.0.0.0/0"
}