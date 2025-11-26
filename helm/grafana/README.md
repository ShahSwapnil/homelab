# Grafana

Setting up Grafana

## Render Template

```pwsh
helm template grafana . -n monitoring --output-dir rendered -f ./values.yaml
```

## Install

```pwsh
helm install grafana . -n monitoring -f ./values.yaml --create-namespace
```

```pwsh
helm upgrade grafana . -n monitoring -f ./values.yaml
```

## Get admin password

```bash
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

```pwsh
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | Foreach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```
