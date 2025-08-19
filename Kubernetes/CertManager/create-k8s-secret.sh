# First, base64 encode your key and certificate chain files.
# The -w0 (or -b0 on BSD/macOS) flag ensures no line wrapping, which is crucial for base64 encoding for Kubernetes secrets.
export CA_CERT_CHAIN_BASE64=$(cat ca-chain.cert.pem | base64 -w0)
export CA_KEY_BASE64=$(cat certmanager-decrypted.key.pem | base64 -w0)

# Now, create the Secret YAML
cat <<EOF > cert-manager-ca-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: cert-manager-ca-key-pair  # Name of the secret, you'll reference this in your ClusterIssuer
  namespace: cert-manager         # Important: This secret should be in the cert-manager namespace
type: kubernetes.io/tls
data:
  tls.crt: ${CA_CERT_CHAIN_BASE64}
  tls.key: ${CA_KEY_BASE64}
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: nscubed-cluster-issuer
spec:
  ca:
    secretName: cert-manager-ca-key-pair
EOF

# Apply the Secret
kubectl apply -f cert-manager-ca-secret.yaml
