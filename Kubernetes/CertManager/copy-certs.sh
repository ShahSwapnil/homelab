#!/bin/bash

# First, base64 encode your key and certificate chain files.
# The -w0 (or -b0 on BSD/macOS) flag ensures no line wrapping, which is crucial for base64 encoding for Kubernetes secrets.
cp /workspaces/homelab/certs/root/ca/certs/ca.cert.pem ./root.cert.pem
cp /workspaces/homelab/certs/root/ca/certmanager/certs/certmanager.cert.pem ./certmanager.cert.pem
cp /workspaces/homelab/certs/root/ca/certmanager/private/certmanager.key.pem ./certmanager.key.pem

cat certmanager.cert.pem root.cert.pem > ca-chain.cert.pem

openssl verify -CAfile root.cert.pem ca-chain.cert.pem

#Decrypt the key
openssl rsa -in certmanager.key.pem -out certmanager-decrypted.key.pem
