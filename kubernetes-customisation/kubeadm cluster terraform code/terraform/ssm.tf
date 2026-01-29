resource "aws_ssm_document" "copy_kubeconfig" {
  name          = "copy-kubeconfig"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Copy kubeconfig to bastion",
    mainSteps = [{
      action = "aws:runShellScript",
      name   = "copyConfig",
      inputs = {
        runCommand = [
          "mkdir -p /home/ubuntu/.kube",
          "cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config",
          "chown -R ubuntu:ubuntu /home/ubuntu/.kube"
        ]
      }
    }]
  })
}
