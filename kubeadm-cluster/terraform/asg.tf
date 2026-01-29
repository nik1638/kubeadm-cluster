resource "aws_launch_template" "worker" {
  name_prefix   = "worker-"
  image_id      = data.aws_ami.ubuntu_worker.id
  instance_type = var.worker_instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.worker_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.worker_sg.id]
  }

  user_data = base64encode(
    templatefile("${path.root}/modules/k8s/user-data/worker.sh", {
      AWS_REGION = var.region
    })
  )
}


resource "aws_autoscaling_group" "worker_asg" {
  launch_template {
    id      = aws_launch_template.worker.id
    version = "$Latest"
  }
  min_size            = var.worker_min_size
  max_size            = var.worker_max_size
  desired_capacity    = var.worker_desired
  vpc_zone_identifier = aws_subnet.private[*].id
  health_check_type   = "EC2"
  force_delete        = true

  tags = [
    {
      key                 = "Name"
      value               = "k8s-worker"
      propagate_at_launch = true
    }
  ]
}
