#!/bin/bash
NODE_IP=$(hostname -I | awk '{print $1}')

set -e

# --- Variables from Terraform
CONTROL_PLANE_ENDPOINT=${control_plane_endpoint}
K8S_VERSION=${k8s_version}
AWS_REGION=${AWS_REGION}

# --- Disable swap permanently
swapoff -a
sed -i '/[[:space:]]swap[[:space:]]/ s/^\(.*\)$/#\1/' /etc/fstab

# --- Load kernel modules persistently
cat <<EOF >/etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# --- sysctl params for Kubernetes networking
cat <<EOF >/etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# --- Install containerd (runtime)
apt-get update
apt-get install -y containerd.io

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# --- Add Kubernetes APT repo
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION%.*}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/k8s.gpg
echo "deb [signed-by=/etc/apt/keyrings/k8s.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION%.*}/deb/ /" \
  > /etc/apt/sources.list.d/k8s.list

apt-get update
apt-get install -y kubelet=${K8S_VERSION}-00 kubeadm=${K8S_VERSION}-00 kubectl=${K8S_VERSION}-00
apt-mark hold kubelet kubeadm kubectl

# --- kubeadm init
kubeadm init \
  --control-plane-endpoint=${CONTROL_PLANE_ENDPOINT}:6443 \
  --upload-certs \
  --pod-network-cidr=192.168.0.0/16 \
  --kubernetes-version=${K8S_VERSION}

# --- Configure kubeconfig
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chmod 600 /root/.kube/config

# --- Install Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# --- Store join command
# JOIN_CMD=$(kubeadm token create --print-join-command)
# aws ssm put-parameter --name "/k8s/join_command" --type String --value "$JOIN_CMD" --overwrite --region ${AWS_REGION}

# echo "Control plane setup complete."

JOIN_CMD=$$(kubeadm token create --print-join-command)
aws ssm put-parameter \
  --name /k8s/join_command \
  --type String \
  --value "$$JOIN_CMD" \
  --overwrite \
  --region ${AWS_REGION}

