#!/bin/bash
set -e

# Disable swap (mandatory)
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Container runtime
apt-get update
apt-get install -y containerd curl

containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# Kubernetes v1.33 repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
 | gpg --dearmor -o /etc/apt/keyrings/k8s.gpg

echo "deb [signed-by=/etc/apt/keyrings/k8s.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" \
 > /etc/apt/sources.list.d/k8s.list

apt-get update

# Install EXACT versions
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Initialize cluster with v1.33
kubeadm init \
  --kubernetes-version v1.33.0 \
  --pod-network-cidr=192.168.0.0/16

# kubeconfig for root
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chown root:root /root/.kube/config

# Save join command for workers
kubeadm token create --print-join-command > /join.sh
chmod +x /join.sh
