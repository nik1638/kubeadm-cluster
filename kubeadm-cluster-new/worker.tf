resource "aws_instance" "worker" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k8s.id]
  key_name               = var.key_name

  user_data = file("${path.module}/scripts/worker_user_data.sh")

  depends_on = [aws_instance.master]

  tags = {
    Name = "k8s-worker-${count.index}"
  }
}
