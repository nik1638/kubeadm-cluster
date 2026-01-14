output "grafana_lb_dns" {
  value = helm_release.grafana.status[0].load_balancer_ingress[0].hostname
}

output "prometheus_lb_dns" {
  value = helm_release.prometheus.status[0].load_balancer_ingress[0].hostname
}

output "jenkins_lb_dns" {
  value = helm_release.jenkins.status[0].load_balancer_ingress[0].hostname
}

output "nginx_ingress_lb_dns" {
  value = helm_release.nginx_ingress.status[0].load_balancer_ingress[0].hostname
}


output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "worker_instance_ids" {
  value = aws_autoscaling_group.workers.instances
}

output "master_private_ips" {
  value = aws_instance.masters[*].private_ip
}
