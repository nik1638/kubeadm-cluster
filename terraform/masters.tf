data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Ubuntu AMI

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "masters" {
  count                   = length(var.public_azs)
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type_master
  subnet_id               = aws_subnet.private[count.index].id
  key_name                = "<YOUR_KEY_NAME>"
  vpc_security_group_ids  = [aws_security_group.master_sg.id]
  associate_public_ip_address = false

  user_data = base64encode(
    templatefile("${path.module}/modules/k8s/user-data/control.sh", {
      control_plane_endpoint = "k8s-control-plane.local",
      k8s_version            = var.k8s_version,
      AWS_REGION             = var.region
    })
  )

  tags = {
    Name = "k8s-master-${count.index + 1}"
  }
}
