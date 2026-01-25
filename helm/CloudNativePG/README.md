# Install CloudNativPG

## Add the official CloudNativePG repository
```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
```

## Update your local repositories
```bash
helm repo update
```

## Install the operator into its own namespace
```bash
helm upgrade --install cnpg-operator cnpg/cloudnative-pg `
  --namespace cnpg-system `
  --create-namespace

```
  

## Example Deployment Cluster

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: budget-db
  namespace: nscubed # Keep it with your app
spec:
  instances: 2 # 1 Primary, 1 Replicas
  imageName: ghcr.io/cloudnative-pg/postgresql:16 # Use a specific version
  
  # Storage configuration
  storage:
    size: 5Gi
  
  # Enable monitoring for Prometheus (optional but recommended)
  monitoring:
    enablePodMonitor: true
```
