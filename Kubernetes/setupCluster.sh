#!/bin/bash

CONTROL_PLANE_IP="192.168.1.68"
WORKER_NODE_ONE_IP="192.168.1.69"
WORKER_NODE_TWO_IP="192.168.1.71"

KUBERNETES_FOLDER_PATH="/workspaces/homelab/Kubernetes"
GENERATE_VM_SCRIPT_PATH="$KUBERNETES_FOLDER_PATH/initializeVM.sh"
PACKAGE_FOLDER_PATH="$KUBERNETES_FOLDER_PATH/Package"
SETUP_KUBERNETES_SCRIPT="$KUBERNETES_FOLDER_PATH/setupKubernetes.sh"

# Create Control Plane
$GENERATE_VM_SCRIPT_PATH -i $CONTROL_PLANE_IP

# Create Worker Node 01
$GENERATE_VM_SCRIPT_PATH -i $WORKER_NODE_ONE_IP

# Create Worker Node 02
$GENERATE_VM_SCRIPT_PATH -i $WORKER_NODE_TWO_IP

if [ -d "$PACKAGE_FOLDER_PATH" ]; then
	echo "Deleting '$PACKAGE_FOLDER_PATH'"
	rm -rf $PACKAGE_FOLDER_PATH
fi

mkdir -p $PACKAGE_FOLDER_PATH

ROOT_CA_FILE_PATH="/workspaces/homelab/certs/root/ca/certs/ca.cert.pem"
K8S_CA_FILE_PATH="/workspaces/homelab/certs/root/ca/kubernetesca/certs/kubernetesca.cert.pem"

# --- Configuration ---
CONTAINERD_VERSION_URL="https://api.github.com/repos/containerd/containerd/releases/latest"
ARCH="amd64"
OS="linux"
RUNC_VERSION_URL="https://api.github.com/repos/opencontainers/runc/releases/latest"
CNI_VERSION_URL="https://api.github.com/repos/containernetworking/plugins/releases/latest"

# --- Main Script ---

echo "Finding the latest containerd version..."
# Use curl and jq to parse the JSON response from the GitHub API
# jq is a powerful tool for parsing JSON from the command line
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install it (e.g., sudo apt-get install jq) and try again." >&2
    exit 1
fi

CONTAINERD_LATEST_VERSION=$(curl -s "$CONTAINERD_VERSION_URL" | jq -r '.tag_name' | sed 's/^v//')
if [ -z "$CONTAINERD_LATEST_VERSION" ]; then
    echo "Error: Could not retrieve the latest version from GitHub." >&2
    exit 1
fi

RUNC_LATEST_VERSION=$(curl -s "$RUNC_VERSION_URL" | jq -r '.tag_name' | sed 's/^v//')
if [ -z "$RUNC_LATEST_VERSION" ]; then
    echo "Error: Could not retrieve the latest version from GitHub." >&2
    exit 1
fi

CNI_LATEST_VERSION=$(curl -s "$CNI_VERSION_URL" | jq -r '.tag_name' | sed 's/^v//')
if [ -z "$CNI_LATEST_VERSION" ]; then
    echo "Error: Could not retrieve the latest version from GitHub." >&2
    exit 1
fi

echo "Latest containerd version found: $CONTAINERD_LATEST_VERSION"
CONTAINERD_DOWNLOAD_URL="https://github.com/containerd/containerd/releases/download/v${CONTAINERD_LATEST_VERSION}/containerd-${CONTAINERD_LATEST_VERSION}-${OS}-${ARCH}.tar.gz"
CONTAINERD_DOWNLOAD_FILE="$PACKAGE_FOLDER_PATH/containerd.tar.gz"

CONTAINERD_SERVICE_URL="https://raw.githubusercontent.com/containerd/containerd/main/containerd.service"
CONTAINERD_SERVICE_DOWNLOAD_FILE="$PACKAGE_FOLDER_PATH/containerd.service"

RUNC_DOWNLOAD_URL="https://github.com/opencontainers/runc/releases/download/v${RUNC_LATEST_VERSION}/runc.amd64"
RUNC_DOWNLOAD_FILE="$PACKAGE_FOLDER_PATH/runc.amd64"

CNI_DOWNLOAD_URL="https://github.com/containernetworking/plugins/releases/download/v${CNI_LATEST_VERSION}/cni-plugins-${OS}-${ARCH}-v${CNI_LATEST_VERSION}.tgz"
CNI_DOWNLOAD_FILE="$PACKAGE_FOLDER_PATH/cni-plugins.tgz"

echo "Downloading containerd from $CONTAINERD_DOWNLOAD_URL..."
curl -sL "$CONTAINERD_DOWNLOAD_URL" -o "$CONTAINERD_DOWNLOAD_FILE"

echo "Downloading containerd.service from $CONTAINERD_SERVICE_URL..."
curl -sL "$CONTAINERD_SERVICE_URL" -o "$CONTAINERD_SERVICE_DOWNLOAD_FILE"

echo "Downloading runc from $RUNC_DOWNLOAD_URL..."
curl -sL "$RUNC_DOWNLOAD_URL" -o "$RUNC_DOWNLOAD_FILE"

echo "Downloading cni from $CNI_DOWNLOAD_URL..."
curl -sL "$CNI_DOWNLOAD_URL" -o "$CNI_DOWNLOAD_FILE"

# Copy Root CA - Control Plane
echo "Copying Root Cert to Control Plane"
$SETUP_KUBERNETES_SCRIPT -i $CONTROL_PLANE_IP -c "$ROOT_CA_FILE_PATH" -p "$PACKAGE_FOLDER_PATH"

# Copy Root CA - Worker Node 01
echo "Copying Root Cert to Worker Node 01"
$SETUP_KUBERNETES_SCRIPT -i $WORKER_NODE_ONE_IP -c "$ROOT_CA_FILE_PATH" -p "$PACKAGE_FOLDER_PATH"

# Copy Root CA - Worker Node 02
echo "Copying Root Cert to Worker Node 02"
$SETUP_KUBERNETES_SCRIPT -i $WORKER_NODE_TWO_IP -c "$ROOT_CA_FILE_PATH" -p "$PACKAGE_FOLDER_PATH"
