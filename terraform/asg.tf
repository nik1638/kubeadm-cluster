# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Ubuntu AMI

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Launch Template for Worker Nodes
resource "aws_launch_template" "workers" {
  name_prefix   = "k8s-worker-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_worker

  # Spot Instance Support
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price          = "0.08" # adjust as needed
      spot_instance_type = "one-time"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.worker_profile.name
  }

  vpc_security_group_ids = [aws_security_group.worker_sg.id]

  # User Data
  user_data = base64encode(
    templatefile("${path.module}/modules/k8s/user-data/worker.sh", {
      control_plane_endpoint = "k8s-control-plane.local",
      k8s_version            = var.k8s_version,
      AWS_REGION             = var.region
    })
  )
}

# Auto Scaling Group for Worker Nodes
resource "aws_autoscaling_group" "workers" {
  name                      = "k8s-workers"
  desired_capacity           = var.desired_workers
  min_size                   = 1
  max_size                   = var.max_workers
  vpc_zone_identifier        = aws_subnet.private[*].id
  health_check_type          = "EC2"

  launch_template {
    id      = aws_launch_template.workers.id
    version = "$Latest"
  }

  # Cluster Autoscaler tag
  tag {
    key                 = "k8s.io/cluster/kubeadm-cluster"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "k8s-worker"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  wait_for_capacity_timeout = "10m"
}
