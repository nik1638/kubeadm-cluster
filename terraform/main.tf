provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "vpc" {
  source = "./modules/vpc"
}

module "k8s" {
  source = "./modules/k8s"
}
