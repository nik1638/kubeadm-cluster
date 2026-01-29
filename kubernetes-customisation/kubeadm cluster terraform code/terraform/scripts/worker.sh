#!/bin/bash
set -e

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

apt-get update
apt-get install -y containerd curl
systemctl restart containerd
systemctl enable containerd

mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
 | gpg --dearmor -o /etc/apt/keyrings/k8s.gpg

echo "deb [signed-by=/etc/apt/keyrings/k8s.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" \
 > /etc/apt/sources.list.d/k8s.list

apt-get update
apt-get install -y kubelet kubeadm
apt-mark hold kubelet kubeadm
