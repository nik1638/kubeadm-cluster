variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_azs" {
  default = ["us-east-1a","us-east-1b","us-east-1c"]
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
