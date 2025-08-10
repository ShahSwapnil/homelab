#!/bin/bash

# --- Default values for optional parameters ---
DEFAULT_MEMORY_STARTUP_BYTES="32GB"
DEFAULT_VHD_SIZE_GB=50
DEFAULT_PROCESSOR_COUNT=4

# --- Variables to store parsed arguments ---
VMNAME=""
MacAddress=""
ProcessorCount=""
MemoryStartupBytes=""
VHDSizeGB=""

# -o v:a:p:m:h:  : Defines short options. Each colon (:) means the option requires an argument.
# --longoptions "": No long options defined in this example, but you could add them like 'verbose'
# "$@": Pass all command-line arguments to getopt
ARGS=$(getopt -o v:a:p:m:h: --longoptions "" -- "$@")

if [ "$#" -eq 0 ]; then
  echo "Error: No argument provided." >&2
  echo "Usage: $0 -v <VMName> -a <MacAddress> -p <ProcessorCount> -m <MemoryStartupBytes> -h <VHDSizeGB>" >&2 # $0 is the script's name
  exit 1 # Exit with a non-zero status to indicate an error
fi

# eval sets the positional parameters to the output of getopt.
# This is vital for getopt to correctly handle arguments with spaces and quoted values.
eval set -- "$ARGS"

while true; do
	case "$1" in 
		-v)
			VMNAME="$2"
			shift 2
			;;
		-a) 
			MacAddress="$2"
			shift 2
			;;
		-p) 
			ProcessorCount="$2"
			shift 2
			;;
		-m)
			MemoryStartupBytes="$2"
			shift 2
			;;
		-h) 
			VHDSizeGB="$2"
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
if [ -z "$VMNAME" ]; then
  echo "Error: The -v parameter is required." >&2
  echo "Usage: $0 -v <VmName>" >&2
  exit 1
fi

if [ -z "$MacAddress" ]; then
  echo "Error: The -a parameter is required." >&2
  echo "Usage: $0 -a <MacAddress>" >&2
  exit 1
fi

: "${ProcessorCount:=$DEFAULT_PROCESSOR_COUNT}"
: "${VHDSizeGB:=$DEFAULT_VHD_SIZE_GB}"
: "${MemoryStartupBytes:=$DEFAULT_MEMORY_STARTUP_BYTES}"

# --- Display Final Parameters ---
echo "--- Script Parameters ---"
printf "%22s %s\n" "VmName:" "$VMNAME"
printf "%22s %s\n" "Mac Address:" "$MacAddress"
printf "%22s %s\n" "Processor Count:" "$ProcessorCount"
printf "%22s %s\n" "Memory Startup Bytes:" "$MemoryStartupBytes"
printf "%22s %s\n" "VHD Size (GB):" "$VHDSizeGB"

WINDOWS_HOST="192.168.1.192"
WINDOWS_USER="swapn"

echo_message() {
	local message="$1"
	local level="$2"

	if [ -z "$level" ]; then
		level="info"
	fi

	case "$level" in 
		info)
			echo -e "\033[35m$message\033[0m"
			;;
		error)
			echo -e "\033[31m$message\033[0m"
			;;
		success)
			echo -e "\033[32m$message\033[0m"
			;;
		warn)
			echo -e "\033[33m$message\033[0m"
			;;
	esac
}

ROOT_WORKSPACE_PATH="/workspaces/homelab/Kubernetes"
LOCAL_PS_SCRIPT="$ROOT_WORKSPACE_PATH/CreateVM.ps1"
REMOTE_PS_DIR="C:/temp"
REMOTE_PS_SCRIPT="$REMOTE_PS_DIR/$(basename "$LOCAL_PS_SCRIPT")"

PS_SCRIPT_PARAMS="-VMName \"$VMNAME\" -MacAddress \"$MacAddress\" -ProcessorCount $ProcessorCount -MemoryStartupBytes $MemoryStartupBytes -VHDSizeGB $VHDSizeGB"

# --- Error Handling Function ---
handle_error() {
  echo "Error on line $1: $2" >&2
  #exit 1
}

# Trap errors to call handle_error
trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

# --- 1. Create remote temp directory (if necessary) ---
echo "Check if VM Already exists"
ssh "$WINDOWS_USER@$WINDOWS_HOST" "pwsh -Command Get-VM -Name $VMNAME"

SSH_EXIT_CODE=$?
if [ $SSH_EXIT_CODE -eq 0 ]; then
    echo "VM Already exists"
    # Now, you need to check if the PowerShell command *itself* had an error
    # (See Section 2 below)
    exit 1 # Exit the bash script
else
    echo "Error: SSH command failed with exit code $SSH_EXIT_CODE." >&2
    if [ $SSH_EXIT_CODE -eq 255 ]; then
        echo "This often indicates a connection problem or SSH server issue." >&2
		exit 1 # Exit the bash script
    fi
fi

# --- 2. Create remote temp directory (if necessary) ---
echo "Ensuring remote directory '$REMOTE_PS_DIR' exists..."
ssh "$WINDOWS_USER@$WINDOWS_HOST" "pwsh -Command if ( -not (Test-Path -Path '$REMOTE_PS_DIR')) { New-Item -Path '$REMOTE_PS_DIR' -ItemType Directory }"
echo "Remote directory checked/created."

# --- 3. Copy the PowerShell script ---
echo "Copying PowerShell script to remote host..."
scp "$LOCAL_PS_SCRIPT" "$WINDOWS_USER@$WINDOWS_HOST:$REMOTE_PS_SCRIPT"
echo "Script copied successfully to $REMOTE_PS_SCRIPT."

# Build the full PowerShell command to execute
# Use double quotes for the outer SSH command, and escape inner double quotes where necessary
# Example: `powershell.exe -File "C:\path\script.ps1" -Param "Value with spaces"`
# becomes: `powershell.exe -File \"C:\\path\\script.ps1\" -Param \"Value with spaces\"`
FULL_PS_COMMAND="pwsh -NoProfile -ExecutionPolicy Bypass -File \"$REMOTE_PS_SCRIPT\" $PS_SCRIPT_PARAMS"

ssh "$WINDOWS_USER@$WINDOWS_HOST" "$FULL_PS_COMMAND"

echo "PowerShell script execution complete."

# --- Optional: Clean up the script from the remote host ---
echo "Cleaning up remote script..."
ssh "$WINDOWS_USER@$WINDOWS_HOST" "pwsh -Command Remove-Item -Path \"$REMOTE_PS_SCRIPT\" -Force"
echo "Remote script cleaned up."

echo "Script finished successfully."
