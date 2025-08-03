#!/bin/bash

PROJECT_PATH="/workspaces/homelab"
SCRIPT_PATH="$PROJECT_PATH/CertificateManagement"
ROOT_SCRIPT_PATH="$SCRIPT_PATH/createRootCertificate.sh"
INTERMEDIATE_SCRIPT_PATH="$SCRIPT_PATH/createIntermediateCertificate.sh"

# Create Root Certificate
$ROOT_SCRIPT_PATH

# Create Kubernetes CA
$INTERMEDIATE_SCRIPT_PATH -n kubernetesca

# Create Certificate Manager CA
$INTERMEDIATE_SCRIPT_PATH -n certmanager
