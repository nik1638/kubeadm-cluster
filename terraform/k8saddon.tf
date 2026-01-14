provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

###############################
# 1️⃣ Metrics Server
###############################
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  values = [file("${path.module}/modules/k8s/addons/metrics-server.yaml")]
}

###############################
# 2️⃣ Cluster Autoscaler
###############################
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  values = [file("${path.module}/modules/k8s/addons/cluster-autoscaler.yaml")]

  set {
    name  = "autoDiscovery.clusterName"
    value = "kubeadm-cluster"
  }

  set {
    name  = "awsRegion"
    value = var.region
  }
}

###############################
# 3️⃣ NGINX Ingress Controller
###############################
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"

  values = [file("${path.module}/modules/k8s/addons/nginx-ingress-values.yaml")]
}

###############################
# 4️⃣ Prometheus
###############################
resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  values = [file("${path.module}/modules/k8s/addons/prometheus-values.yaml")]
}

###############################
# 5️⃣ Grafana
###############################
resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = "monitoring"
  create_namespace = false

  values = [file("${path.module}/modules/k8s/addons/grafana-values.yaml")]
}

###############################
# 6️⃣ Jenkins
###############################
resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  namespace        = "ci"
  create_namespace = true

  values = [file("${path.module}/modules/k8s/addons/jenkins-values.yaml")]
}

###############################
# 7️⃣ AWS EBS CSI Driver
###############################
resource "helm_release" "ebs_csi" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"

  values = [file("${path.module}/modules/k8s/addons/ebs-csi-values.yaml")]
}
