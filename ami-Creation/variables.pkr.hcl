variable "ami_name" {
  type        = string
  description = "The name of the AMI to create"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for building the image"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "security_group_id" {
  type        = string
  description = "Security Group ID"
}

variable "ssh_username" {
  type        = string
  description = "SSH username for the base AMI"
}

variable "ami_filters" {
  type = map(string)
  description = "Filters for selecting the source AMI"
}

variable "ami_owners" {
  type = list(string)
  description = "List of AMI owners"
}
