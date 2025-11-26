# Open Telemetry Kube Stack

## Template

```pwsh
Remove-Item -Path rendered -Force -Confirm -Recurse
helm template otel . -n monitoring --output-dir rendered -f values.yaml
```

## Install
```pwsh
helm install otel . -n monitoring --render-subchart-notes
```

## Upgrade
```pwsh
helm upgrade otel . -n monitoring 
```

## Notes

NOTES:
kube-state-metrics is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.
The exposed metrics can be found here:
https://github.com/kubernetes/kube-state-metrics/blob/master/docs/README.md#exposed-metrics

The metrics are exported on the HTTP endpoint /metrics on the listening port.
In your case, otel-kube-state-metrics.monitoring.svc.cluster.local:8080/metrics

They are served either as plaintext or protobuf depending on the Accept header.
They are designed to be consumed either by Prometheus itself or by a scraper that is compatible with scraping a Prometheus client endpoint.

1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=prometheus-node-exporter,app.kubernetes.io/instance=otel" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:9100 to use your application"
  kubectl port-forward --namespace monitoring $POD_NAME 9100

[WARNING] No resource limits or requests were set. Consider setter resource requests and limits via the `resources` field.


opentelemetry-operator has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "app.kubernetes.io/instance=otel"

Visit https://github.com/open-telemetry/opentelemetry-operator for instructions on how to create & configure OpenTelemetryCollector and Instrumentation custom resources by using the Operator.
