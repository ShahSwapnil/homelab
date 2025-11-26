# Prometheus

## Template

```pwsh
helm template prometheus . -n monitoring --output-dir rendered
```

## Install

```pwsh
helm install prometheus . -n monitoring --render-subchart-notes
```

## Upgrade

```pwsh
helm upgrade prometheus . -n monitoring 
```

## Notes

NOTES:
1. Get the application URL by running these commands:
  ```bash
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=prometheus-pushgateway,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl port-forward $POD_NAME 9091
  ```

  Visit http://127.0.0.1:9091 to use your application

The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
`prometheus-server.monitoring.svc.cluster.local`


Get the Prometheus server URL by running these commands in the same shell:
```bash
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9090
```

The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
`prometheus-prometheus-pushgateway.monitoring.svc.cluster.local`


Get the PushGateway URL by running these commands in the same shell:
```bash
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus-pushgateway,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9091
```
