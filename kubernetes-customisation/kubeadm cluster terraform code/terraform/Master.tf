resource "aws_instance" "master" {
  ami           = "ami-0f5ee92e2d63afc18" # Ubuntu 22.04
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_name
  security_groups = [aws_security_group.k8s.id]

  user_data = file("scripts/master.sh")

  tags = {
    Name = "k8s-master"
  }
}
