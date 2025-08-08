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

# --- Configuration ---
KEY_IDENTIFIER="DevContainer" # The comment or part of the comment for your key

# --- Get Public Key Content from ssh-agent ---
PUBLIC_KEY_CONTENT=$(ssh-add -L | grep "$KEY_IDENTIFIER" | head -n 1)

if [ -z "$PUBLIC_KEY_CONTENT" ]; then
    echo "Error: Public key with identifier '$KEY_IDENTIFIER' not found in ssh-agent." >&2
    echo "Ensure your key is loaded (ssh-add) and its comment matches '$KEY_IDENTIFIER'." >&2
    exit 1
fi

echo "Public Key Content from ssh-agent:"
echo "SSH Public Key: $PUBLIC_KEY_CONTENT"

echo "--- Script Parameters ---"
printf "%10s %s\n" "IP Address:" "$IP_ADDRESS"

# --- Corrected SSH command with unquoted EOF and escaped remote variables ---
ssh "$USER@$IP_ADDRESS" << EOF
# This script block runs on the remote server
# Note: Variables like \$HOME, \$PERMISSIONS, etc., are escaped so the remote shell interprets them.
# PUBLIC_KEY_CONTENT is NOT escaped, so the local shell substitutes its value here.

# Check and create .ssh directory
if [ -d "\$HOME/.ssh" ]; then
    echo "'\$HOME/.ssh' folder exists."
else
    echo "'\$HOME/.ssh' folder doesn't exist."
	exit 1
fi

# Check and set permissions on .ssh directory
# Note: \$FOLDER_PATH was undefined in your original remote script. Changed to \$HOME/.ssh
PERMISSIONS=\$(stat -c "%a" "\$HOME/.ssh")

if [ "\$PERMISSIONS" = "700" ]; then
    echo "Permissions on '\$HOME/.ssh' are correctly set to 700."
else
    echo "Warning: Permissions on '\$HOME/.ssh' are \$PERMISSIONS, not 700."
fi

# Check and create authorized_keys file
if [ -f "\$HOME/.ssh/authorized_keys" ]; then
    echo "File '\$HOME/.ssh/authorized_keys' exists"
else
    # touch needs to be run by the user, not sudo if authorized_keys needs to be owned by user
    # If the parent directory was just created by sudo, ownership might be root.
    # It's safer to ensure correct ownership.
    sudo touch "\$HOME/.ssh/authorized_keys"
    echo "File '\$HOME/.ssh/authorized_keys' created"
fi

# Check and set permissions on authorized_keys file
# Note: \$PERMISSIONS was used instead of \$FILE_PERMISSIONS in original. Corrected.
FILE_PERMISSIONS=\$(stat -c "%a" "\$HOME/.ssh/authorized_keys")

if [ "\$FILE_PERMISSIONS" = "600" ]; then
    echo "Permissions on '\$HOME/.ssh/authorized_keys' are correctly set to 600."
else
    echo "Warning: Permissions on '\$HOME/.ssh/authorized_keys' are \$FILE_PERMISSIONS, not 600."
fi

# Check if key is already present and add if not
# The PUBLIC_KEY_CONTENT variable's VALUE is interpolated here by the local shell
# The remote grep command will then see the actual key string.
if grep -qF "$PUBLIC_KEY_CONTENT" "\$HOME/.ssh/authorized_keys"; then
    echo "SSH Key Already added"
else
    echo "$PUBLIC_KEY_CONTENT" >> "\$HOME/.ssh/authorized_keys"
    echo "SSH Key Added"
fi

EOF

ssh "$USER@$IP_ADDRESS" << EOF

echo "Hello"

EOF
