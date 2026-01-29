#!/bin/bash
set -e

# ------------------------------
# Variables from Terraform
# ------------------------------
CONTROL_PLANE_ENDPOINT=${control_plane_endpoint}
K8S_VERSION=${k8s_version}
AWS_REGION=${AWS_REGION}

# ------------------------------
# Disable swap permanently
# ------------------------------
swapoff -a
sed -i '/[[:space:]]swap[[:space:]]/ s/^\(.*\)$/#\1/' /etc/fstab

# ------------------------------
# Load kernel modules persistently
# ------------------------------
cat <<EOF >/etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# ------------------------------
# Sysctl params for Kubernetes networking
# ------------------------------
cat <<EOF >/etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# ------------------------------
# Install containerd runtime
# ------------------------------
apt-get update
apt-get install -y containerd.io

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# ------------------------------
# Add Kubernetes APT repository
# ------------------------------
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION%.*}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/k8s.gpg
echo "deb [signed-by=/etc/apt/keyrings/k8s.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION%.*}/deb/ /" \
  > /etc/apt/sources.list.d/k8s.list

apt-get update
apt-get install -y kubelet=${K8S_VERSION}-00 kubeadm=${K8S_VERSION}-00 kubectl=${K8S_VERSION}-00
apt-mark hold kubelet kubeadm kubectl

# ------------------------------
# Wait for SSM join command
# ------------------------------
echo "Waiting for SSM join command..."
until JOIN_CMD=$(aws ssm get-parameter --name "/k8s/join_command" --region ${AWS_REGION} --query "Parameter.Value" --output text); do
  echo "Join command not ready yet. Sleeping 10s..."
  sleep 10
done

# ------------------------------
# Join the cluster
# ------------------------------
JOIN_CMD=$$(aws ssm get-parameter \
  --name /k8s/join_command \
  --query 'Parameter.Value' \
  --output text \
  --region ${AWS_REGION})
bash -c "$$JOIN_CMD"


# ------------------------------
# Done
# ------------------------------
echo "Worker node successfully joined the cluster."
