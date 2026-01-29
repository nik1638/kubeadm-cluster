#!/bin/bash
set -euxo pipefail

#MASTER_IP="${master_ip}"

#######################################
# Disable swap (required for Kubernetes)
#######################################
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

#######################################
# Kernel modules & sysctl
#######################################
cat <<EOF >/etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF >/etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

#######################################
# Install containerd
#######################################
apt-get update -y
apt-get install -y curl gnupg2 apt-transport-https ca-certificates containerd

mkdir -p /etc/containerd
containerd config default >/etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

#######################################
# Install Kubernetes components
#######################################
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" \
  >/etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -y kubelet kubeadm
apt-mark hold kubelet kubeadm

#######################################
# Wait for join script from master
#######################################
# echo "Waiting for join script from master (${MASTER_IP})..."

# until curl -sf http://${MASTER_IP}:8080/join.sh >/dev/null; do
#   sleep 10
# done

# #######################################
# # Join cluster
# #######################################
# curl -sf http://${MASTER_IP}:8080/join.sh | bash
