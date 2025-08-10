#!/bin/bash

IP_ADDRESS=""
USER="neil"

# -o i: : Defines short option 'i' which requires an argument.
# --longoptions "": No long options defined in this example.
ARGS=$(getopt -o i: --longoptions "" -- "$@")

if [ "$#" -eq 0 ]; then
  echo "Error: No argument provided." >&2
  echo "Usage: $0 -i <IPAddress>" >&2 # $0 is the script's name
  exit 1 # Exit with a non-zero status to indicate an error
fi

# eval sets the positional parameters to the output of getopt.
# This is vital for getopt to correctly handle arguments with spaces and quoted values.
eval set -- "$ARGS"

while true; do
    case "$1" in
        -i)
            IP_ADDRESS="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error: Unrecognized option '$1'" >&2
            exit 1
            ;;
    esac
done

# --- 1. Validate Required Parameters ---
if [ -z "$IP_ADDRESS" ]; then
  echo "Error: The -i parameter is required." >&2
  echo "Usage: $0 -i <IP_Address>" >&2
  exit 1
fi

echo "--- Script Parameters ---"
printf "%10s %s\n" "IP Address:" "$IP_ADDRESS"

ssh "$USER@$IP_ADDRESS" << EOF

if kubectl cluster-info 2>&1 | grep -q "was refused"; then
	echo "Kubenetes Cluster not found"
	
	echo "Creating Kubernetes cluster"
	sudo kubeadm init --skip-phases=addon/kube-proxy >> /media/setup/k8s-init.txt

	sudo mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown 644 $HOME/.kube/config

	export KUBECONFIG=$HOME/.kube/config
else
	echo "Kubernetes Cluster found"
fi

EOF

echo "Copying Kubernetes Cluster Info"
scp "$USER@$IP_ADDRESS":/media/setup/k8s-init.txt /workspaces/homelab/Kubernetes/cluster/K8s-cluster-init.txt
scp "$USER@$IP_ADDRESS":/media/setup/kube-config /workspaces/homelab/Kubernetes/cluster/kube-config

sudo mkdir -p $HOME/.kube
cp /workspaces/homelab/Kubernetes/cluster/kube-config $HOME/.kube/config
