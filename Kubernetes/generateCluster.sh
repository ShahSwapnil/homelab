#!/bin/bash

KUBERNETES_FOLDER_PATH="/workspaces/homelab/Kubernetes"
GENERATE_VM_SCRIPT_PATH="$KUBERNETES_FOLDER_PATH/generateVM.sh"

# Create Control Plane
 ./generateVM.sh -v nsc-k8s-cp-01 -a "00155D00C709" -p 2 -m '8GB' -h 100
 ./setupSSH.sh -i "192.168.1.68"

# Create Worker Node 01
 ./generateVM.sh -v nsc-k8s-wn-01 -a "00155D00C70A" -p 5 -m '32GB' -h 100
 ./setupSSH.sh -i "192.168.1.69"

# Create Worker Node 02
 ./generateVM.sh -v nsc-k8s-wn-02 -a "00155D00C70C" -p 5 -m '32GB' -h 100
 ./setupSSH.sh -i "192.168.1.71"

echo "Remove the password requirement when using sudo"
echo "sudo echo "neil ALL=(ALL) NOPASSWD: ALL" >> sudo /etc/sudoers.d/neil"
