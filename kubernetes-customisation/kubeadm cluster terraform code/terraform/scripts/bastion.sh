#!/bin/bash
set -e

apt-get update
apt-get install -y curl awscli

curl -LO https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

mkdir -p /home/ubuntu/.kube
chown -R ubuntu:ubuntu /home/ubuntu/.kube
