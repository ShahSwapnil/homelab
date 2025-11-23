#!/bin/bash

CONTAINER_RUNTIME_VERSION=2.2.0
RUNC_VERSION=v1.3.3
CNI_VERSION=v1.8.0

mkdir -p /usr/local/bin

curl -L -O https://github.com/containerd/containerd/releases/download/v$CONTAINER_RUNTIME_VERSION/containerd-$CONTAINER_RUNTIME_VERSION-linux-amd64.tar.gz

tar Cxzvf /usr/local containerd-$CONTAINER_RUNTIME_VERSION-linux-amd64.tar.gz

mkdir -p /usr/local/lib/systemd/system

curl -L -o /usr/local/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

echo "Daemon Reload"
systemctl daemon-reload

echo "Enable Conatinerd"
systemctl enable --now containerd

# Download and Install runc

mkdir -p /usr/local/sbin

curl -L -O https://github.com/opencontainers/runc/releases/download/$RUNC_VERSION/runc.amd64

echo "Install runc"
install -m 755 runc.amd64 /usr/local/sbin/runc

# Download and Install CNI Plugins

curl -L -O https://github.com/containernetworking/plugins/releases/download/$CNI_VERSION/cni-plugins-linux-amd64-v1.8.0.tgz

mkdir -p /opt/cni/bin

tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-$CNI_VERSION.tgz

mkdir -p /etc/containerd

echo "Creating Config"
containerd config default | tee /etc/containerd/config.toml > /dev/null
