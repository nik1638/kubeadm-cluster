# Worker IAM Role
resource "aws_iam_role" "worker_role" {
  name = "k8s-worker-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "worker_policy" {
  name = "k8s-worker-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "autoscaling:*",
        "ec2:*",
        "elasticloadbalancing:*",
        "iam:CreateServiceLinkedRole",
        "ssm:GetParameter",
        "ssm:PutParameter"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_attach" {
  role       = aws_iam_role.worker_role.name
  policy_arn = aws_iam_policy.worker_policy.arn
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "k8s-worker-profile"
  role = aws_iam_role.worker_role.name
}
