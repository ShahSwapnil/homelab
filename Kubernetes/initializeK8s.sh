#!/bin/bash

IP_ADDRESS=""
USER="neil"
CERT_PATH=""

# -o i: : Defines short option 'i' which requires an argument.
# --longoptions "": No long options defined in this example.
ARGS=$(getopt -o i:c: --longoptions "" -- "$@")

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
		-k)
			CERT_KEY_PATH="$2"
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

echo "--- Script Parameters ---"
printf "%10s %s\n" "IP Address:" "$IP_ADDRESS"
printf "%10s %s\n" "Cert Path:" "$CERT_PATH"

