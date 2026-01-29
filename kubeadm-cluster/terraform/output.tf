output "grafana_nodeport" {
  value = helm_release.grafana.values
}

output "prometheus_nodeport" {
  value = helm_release.prometheus.values
}

output "jenkins_nodeport" {
  value = helm_release.jenkins.values
}

output "nginx_nodeport" {
  value = helm_release.nginx_ingress.values
}


output "worker_asg_name" {
  value = aws_autoscaling_group.worker_asg.name
}
