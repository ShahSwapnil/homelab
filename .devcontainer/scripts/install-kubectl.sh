#!/bin/bash

echo "Download kubectl"
curl -LO https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl

echo "Download kubectl sha256"
curl -LO "https://dl.k8s.io/release/v1.33.0/bin/linux/amd64/kubectl.sha256"

echo "verify checksum"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

echo "Install Kubectl"
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

echo "Install Helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm repo add cilium https://helm.cilium.io/

curl -L https://github.com/derailed/k9s/releases/download/v0.50.9/k9s_Linux_amd64.tar.gz -o k9s.tar.gz
tar -xvf k9s.tar.gz
# mv k9s /usr/local/bin
