#!/bin/bash

IP_ADDRESS=""
USER="neil"
CERT_PATH=""
PACKAGE_FOLDER_PATH=""

# -o i: : Defines short option 'i' which requires an argument.
# --longoptions "": No long options defined in this example.
ARGS=$(getopt -o i:c:p: --longoptions "" -- "$@")

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
		-c) 
			CERT_PATH="$2"
            shift 2
			;;
		-p)
			PACKAGE_FOLDER_PATH="$2"
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

# --- 1. Validate Required Parameters ---
if [ -z "$CERT_PATH" ]; then
  echo "Error: The -c parameter is required." >&2
  echo "Usage: $0 -c <CertFilePath>" >&2
  exit 1
fi

# --- 1. Validate Required Parameters ---
if [ -z "$PACKAGE_FOLDER_PATH" ]; then
  echo "Error: The -c parameter is required." >&2
  echo "Usage: $0 -c <CertFilePath>" >&2
  exit 1
fi

echo "--- Script Parameters ---"
printf "%10s %s\n" "IP Address:" "$IP_ADDRESS"
printf "%10s %s\n" "Cert Path:" "$CERT_PATH"


ssh "$USER@$IP_ADDRESS" << EOF

echo "Deleting Setup folder"
sudo rm -rf /media/setup

echo "Creating setup folder"
sudo mkdir -p /media/setup

echo "Change Permissions"
sudo chown -R neil:neil /media/setup

EOF

echo "Copy Root Cert to VM"
scp $CERT_PATH "$USER@$IP_ADDRESS":/media/setup/rootCA.crt

echo "Copying Packages Folder"
scp -r "$PACKAGE_FOLDER_PATH"/* "$USER@$IP_ADDRESS":/media/setup

ssh "$USER@$IP_ADDRESS" << EOF

if [!  -f "/usr/local/share/ca-certificates/rootCA.crt" ]; then
	echo "Copy Cert to ca-certificates directory"
	sudo cp /media/setup/rootCA.crt /usr/local/share/ca-certificates/rootCA.crt

	echo "Update Trusted CA" 
	sudo update-ca-certificates
fi

echo "Disable Swap"
sudo swapoff -a

FSTAB_FILE="/etc/fstab"
SEARCH_PATTERN="swap"
COMMENTED_PATTERN="^#.*swap"

echo "Search Pattern: $SEARCH_PATTERN"

# Check if the line to be commented exists
if grep swap /etc/fstab; then
  echo "Found a line containing 'swap' in /etc/fstab."

  # Check if the line is already commented out
  if grep "^#.*swap" /etc/fstab; then
    echo "The line is already commented out. No action needed."
  else
    echo "The line is not commented out. Proceeding to comment it."
    
    # Use sed to comment out the line
    sudo sed -i "/swap/s/^/#/" /etc/fstab

	grep swap /etc/fstab
  fi
else
  echo "No line containing 'swap' found in /etc/fstab. No action needed."
fi

echo "Apply sysctl Parameters"
sudo sysctl --system

if [ ! -f "/usr/local/bin/containerd" ]; then
	echo "Unzip Containerd Release"
	sudo tar Cxzvf /usr/local /media/setup/containerd.tar.gz
else
	echo "Containerd Release already unzipped"
fi

if [ ! -f "/usr/local/lib/systemd/system/containerd.service" ]; then
	echo "Creating '/usr/local/lib/systemd/system'"
	sudo mkdir -p /usr/local/lib/systemd/system

	echo "Copying containerd.service"
	sudo cp /media/setup/containerd.service /usr/local/lib/systemd/system
else
	echo "containerd.service already exists"
fi

echo "Reloading daemon"
sudo systemctl daemon-reload

echo "Enabling containerd"
sudo systemctl enable --now containerd

if [ ! -f "/usr/local/sbin/runc" ]; then
	echo "Creating '/usr/local/sbin'"
	sudo mkdir -p /usr/local/sbin

	echo "Installing runc"
	sudo install -m 755 /media/setup/runc.amd64 /usr/local/sbin/runc
else
	echo "runc already installed"
fi

if [ ! -f "/opt/cni/bin/LICENSE" ]; then
	echo "Creating '/opt/cni/bin'"
	sudo mkdir -p /opt/cni/bin

	echo "Unzipping cni-plugin"
	sudo tar Cxzvf /opt/cni/bin /media/setup/cni-plugins.tgz
else
	echo "cni plugin already unzipped"
fi

if [ ! -f "/etc/containerd/config.toml" ]; then
	echo "creating '/etc/containerd'"
	sudo mkdir -p /etc/containerd

	echo "granting neil permissions for '/etc/containerd'"
	sudo chown -R neil:neil /etc/containerd

	echo "Creating containerd config"
	sudo containerd config default > /etc/containerd/config.toml

	# sudo chmod 755 /etc/containerd/config.toml
	echo "updating containerd config"
	sudo sed -i "/runc.options/a\            SystemdCgroup = true" /etc/containerd/config.toml

	grep -A 3 runc.options /etc/containerd/config.toml
else
	echo "Containerd Config already exists"
fi

echo "Update"
sudo apt-get update

echo "Installing apt-transport-https, ca-certificates, curl, gpg"
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

echo "creating '/etc/apt/keyrings'"
sudo mkdir -p -m 755 /etc/apt/keyrings

echo "Download Release Key"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "Add Key for k8s sources"
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Update now that we added K8s sources"
sudo apt-get update

echo "Install kubelet, kubeadm, kubectl"
sudo apt-get install -y kubelet kubeadm kubectl

echo "Stop auto updates for kubelet, kubeadm, kubectl"
sudo apt-mark hold kubelet kubeadm kubectl
EOF
