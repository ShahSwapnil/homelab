# Setting up Harbor on a Kubernetes Homelab <!-- omit in toc -->

This guide provides a step-by-step walkthrough for installing and configuring Harbor, a private container registry, in your Kubernetes cluster using Helm.

- [Prerequisites](#prerequisites)
- [Add the Harbor Helm Repository](#add-the-harbor-helm-repository)
- [Create a Namespace for Harbor](#create-a-namespace-for-harbor)
- [Create a Certificate for Harbor](#create-a-certificate-for-harbor)
- [Create a values.yaml Configuration File](#create-a-valuesyaml-configuration-file)
- [Install Harbor with Helm](#install-harbor-with-helm)

## Prerequisites

Before you begin, ensure you have the following ready:

- [x] Helm: Installed on your local machine.

- [x] Kubernetes Cluster: A running cluster with a default storage class (such as Longhorn).

- [x] DNS Name: A DNS entry pointing to your Harbor instance (e.g., harbor.nscubed.lan). This should be configured in your local DNS server (e.g., Pi-hole).

- [x] Cert-Manager: Installed in your cluster for SSL certificate management.

## Add the Harbor Helm Repository

Add the official Helm repository for Harbor to your local Helm configuration and update it.

```Bash
helm repo add harbor https://helm.goharbor.io
helm repo update
```

## Create a Namespace for Harbor

Create a dedicated namespace to install Harbor, which is a recommended best practice for organizational purposes.

```Bash
kubectl create namespace harbor
```

## Create a Certificate for Harbor

Use Cert-Manager to create a TLS certificate for your Harbor instance. This certificate will be stored in a Kubernetes secret.

```yaml

apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: harbor-cert
  namespace: harbor
spec:
  secretName: harbor-tls-secret
  dnsNames:
  - harbor.nscubed.lan
  issuerRef:
    name: letsencrypt-prod # Or the name of your ClusterIssuer
    kind: ClusterIssuer
```

Apply this manifest to your cluster.

```bash

kubectl apply -f <filename>.yaml
```

## Create a values.yaml Configuration File

Create a values.yaml file to customize your Harbor installation. This file tells Helm to use an Ingress for exposure, specifies your hostname, and configures persistence with your Longhorn storage class.

```yaml

# values.yaml
expose:
  type: ingress
  ingress:
    hosts:
      core: harbor.nscubed.lan
    annotations:
      kubernetes.io/ingress.class: "cilium" # Use cilium for ingress
    tls:
      core:
        secretName: harbor-tls-secret # Reference the secret created by Cert-Manager

externalURL: https://harbor.nscubed.lan

# Configure persistence to use the Longhorn storage class
persistence:
  persistentVolumeClaim:
    registry:
      storageClass: longhorn
    chartmuseum:
      storageClass: longhorn
    jobservice:
      storageClass: longhorn
    database:
      storageClass: longhorn
    redis:
      storageClass: longhorn

# Set a strong password for the default admin user
harborAdminPassword: "MyStrongAdminPassword"
```

## Install Harbor with Helm

Finally, run the helm install command with your customized values.yaml file to deploy Harbor.

```bash
helm install harbor harbor/harbor --namespace harbor -f values.yaml
```

Harbor will now be installed and configured in your cluster. You can check the status of the pods with kubectl get pods -n harbor.

Once all pods are running, you can access your private container registry at [https://harbor.nscubed.lan](https://harbor.nscubed.lan) using the admin username and the password you set.
