provider "aws" {
  region = var.region
}

# resource "aws_key_pair" "k8s" {
#   key_name   = "k8s-key"
#   public_key = var.ssh_public_key
# }

resource "aws_security_group" "k8s" {
  name   = "k8s-sg"
  vpc_id = aws_vpc.k8s.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  self            = true
}

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_key_pair" "k8s" {
#   key_name   = "k8s-shared-key"
#   public_key = var.ssh_public_key
# }
