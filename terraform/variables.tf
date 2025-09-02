variable "project_name" {
  type        = string
  description = "Name prefix for resources"
  default     = "bcm10"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "key_name" {
  type        = string
  description = "Existing AWS key pair for SSH"
}

variable "admin_cidr" {
  type        = string
  description = "Your /32 for SSH/Base View (e.g., 198.51.100.10/32)"
}

variable "head_instance_type" {
  type        = string
  description = "EC2 instance type for head node"
  default     = "c6i.large"
}

variable "head_ami_id" {
  type        = string
  description = "Supported AMI ID (Rocky 9, Ubuntu 22.04, etc.)"
}

variable "enable_egress_internet" {
  type        = bool
  description = "Create NAT & private route for future expansion"
  default     = true
}
