data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # official Ubuntu owner

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-24.04-amd64-server-*"]
  }
}
