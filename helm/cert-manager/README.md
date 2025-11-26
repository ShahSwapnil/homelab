# Cert Manager

Certificate Manager helps provide certs to the cluster when needed. Once the Cert Manager is installed, an Issuer needs to be created. A Cluster Issuer for a homelab is ideal. If a certificate is provided as a secret, Cert-Manager will use that. This way, a Self-Signed CA Cert signed by a Root Cert can be provided. 

## Install

Install the Gateway CRDs before installing Cert Manager. 

```pwsh
helm install cert-manager oci://quay.io/jetstack/charts/cert-manager `
    --version v1.19.1 `
    --namespace cert-manager `
    --create-namespace `
    --set crds.enabled=true `
    --set config.apiVersion="controller.config.cert-manager.io/v1alpha1" `
    --set config.kind="ControllerConfiguration" `
    --set config.enableGatewayAPI=true
```

Use the powershell script in the manifest folder to create a Secret. 

Copy the Secret into `ClusterIssuer.yaml` 

Create the secret and Cluster Issuer. 

```pwsh
kubectl apply -f ./manifest/ClusterIssuer.yaml
```

Since the cert manager was setup with Gateway API, the following annotation can be added to gateway manifest

```yaml
metadata:
  annotations:
    cert-manager.io/cluster-issuer: nscubed-cluster-issuer
```

This will have the cert manager create and manage the certificate for the that gateway. 
