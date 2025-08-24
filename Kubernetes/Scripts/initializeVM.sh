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

echo "Updating apt"
sudo apt -y upgrade

echo "Updating apt-get"
sudo apt-get -y update

echo "Installing nano"
sudo apt-get install nano

echo "Installing Hyper-V integration utilities"
sudo apt -y install linux-virtual linux-cloud-tools-virtual linux-tools-virtual

echo "Updating initramfs"
sudo update-initramfs -u

if [ !-d "/media/setup" ]; then
	echo "Creating '/media/setup' directory"
	sudo mkdir -p /media/setup
	sudo chown -R neil:neil /media/setup
fi

sudo apt-get install wireguard -y

echo "Rebooting VM"
sudo reboot
EOF
