variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "k8s_version" {
  default = "1.33.0-00"
}

variable "desired_workers" {
  default = 2
}

variable "max_workers" {
  default = 5
}

variable "instance_type_worker" {
  default = "t3.medium"
}

variable "instance_type_master" {
  default = "t3.medium"
}

variable "worker_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}


variable "worker_min_size" {
  type    = number
  default = 1
}

variable "worker_max_size" {
  type    = number
  default = 3
}

variable "worker_desired" {
  type    = number
  default = 2
}

