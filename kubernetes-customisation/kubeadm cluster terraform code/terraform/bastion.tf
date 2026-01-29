resource "aws_instance" "bastion" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name
  security_groups = [aws_security_group.k8s.id]

  depends_on = [
    aws_instance.master,
    aws_instance.worker
  ]

  user_data = file("scripts/bastion.sh")

  tags = {
    Name = "bastion"
  }
}

resource "null_resource" "copy_kubeconfig" {
  depends_on = [aws_instance.bastion]

  provisioner "file" {
    source      = "/etc/kubernetes/admin.conf"
    destination = "/home/ubuntu/.kube/config"

    connection {
      host        = aws_instance.bastion.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }
  }
}

provisioner "remote-exec" {
  inline = [
    "sleep 60",
    "sudo /join.sh"
  ]

  connection {
    host        = self.private_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }
}

