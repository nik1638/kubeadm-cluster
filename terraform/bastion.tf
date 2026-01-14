data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Ubuntu AMI owner

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[0].id
  associate_public_ip_address = true
  key_name               = "<YOUR_KEY_NAME>" # Replace with your SSH key
  vpc_security_group_ids = [aws_security_group.worker_sg.id] # Allow SSH

  tags = {
    Name = "k8s-bastion"
  }
}
