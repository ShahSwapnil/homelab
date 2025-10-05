# Overview

How to setup Metrics Observability. OTEL Collectors + Target Allocator + Prometheus + Grafana

## Install CRDs

[Prometheus CRDS - Helm Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-operator-crds)

Prometheus Community has a helm chart just to install Prometheus Helm Charts.

```bash
helm install prometheus-crds oci://ghcr.io/prometheus-community/charts/prometheus-operator-crds -f prometheus-crds.values.yaml -n prometheus-operator
```

You can customize the helm chart by overriding the values.yaml.

```bash
helm show values oci://ghcr.io/prometheus-community/charts/prometheus-operator-crds > prometheus-crds.values.yaml
```

## Install Prometheus

[Prometheus Helm Chart](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/README.md)

Same as before - grab the values.yaml

```bash
helm show values oci://ghcr.io/prometheus-community/charts/prometheus > prometheus.values.yaml
```
