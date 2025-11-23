#!/bin/bash

echo "apt-get Update"
apt-get update

echo "install packages: apt-transport-https ca-certificates curl gpg"
apt-get install -y apt-transport-https ca-certificates curl gpg

echo "Create directory /etc/apt/keyrings"
mkdir -p -m 755 /etc/apt/keyrings

echo "Download the Release Key"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "overwrite any existing k8s configuration"
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

echo "apt-get update"
apt-get update 

echo "install kubelet kubeadm kubectl"
apt-get install -y kubelet kubeadm kubectl

echo "Hold kubelet kubeadm kubectl"
apt-mark hold kubelet kubeadm kubectl

echo "start kubelet"
systemctl enable --now kubelet
