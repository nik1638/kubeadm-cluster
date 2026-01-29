resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  key_name                    = "bastion.key"                     # Replace with your SSH key
  vpc_security_group_ids      = [aws_security_group.worker_sg.id] # Allow SSH

  tags = {
    Name = "k8s-bastion"
  }
}
