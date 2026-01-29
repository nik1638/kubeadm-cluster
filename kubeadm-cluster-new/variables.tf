variable "region" {
  default = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID (Golden or Canonical)"
  type        = string
}

variable "instance_type" {
  default = "t3.medium"
}

variable "ssh_private_key_path" {
  description = "Path to PEM file downloaded from AWS"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}
