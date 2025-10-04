# Setup Monitoring

Notes, Thoughts and Steps to setup OpenTelemetry + Grafana Monitoring Stack

## Goal

Use OpenTelemetry + Grafana + Loki + Tempo + Prometheus for monitoring the cluster and application.

## Helm Chart

### Add OpenTelemetry Helm Chart Repo

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
```

Run helm repo update to update helm registry

```bash
helm repo update
```

### Setup OTEL + Loki + Grafana

- [ ] Grafana[^1]
- [ ] Loki[^2]
- [ ] OTEL[^3]

[^1]: [Grafana Helm Chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana)
[^2]: [Loki Helm Chart](https://github.com/grafana/helm-charts/tree/main/charts/loki-distributed)
[^3]: [OpenTelemetry Helm Charts](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main)

#### Grafana Setup

Going to sub chart the Grafana helm chart, so we can include a http route. The http route is going to be necessary for grafana to be reachable from outside the cluster.

Add the following yaml to a file named `httproute.yaml` in the template folder.

```yaml
---
{{- if .Values.httpRoute.enabled }}
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ include "httpRoute.name" . }}
  namespace: {{ .Values.namespace }} # The namespace where your application service is located
spec:
  parentRefs:
  - name: {{ .Values.httpRoute.parentRefs.name }}
    namespace: {{ .Values.httpRoute.parentRefs.namespace }} # The namespace where your Gateway is located
  hostnames:
  {{- range .Values.httpRoute.hostNames }}
  - {{ . | quote }}
  {{- end}}
  rules:
  - backendRefs:
  {{- range .Values.httpRoute.backendRefs }}
    - name: {{ .name }}
      port: {{ .port }}
  {{- end }}
{{- end }}
```

in the values.yaml Define the following values

```yaml
namespace: grafana

httpRoute:
  enabled: true
  hostNames:
    - grafana.nscubed.lan
  parentRefs:
    name: http-gateway
    namespace: kube-system
  backendRefs:
    - name: grafana
      port: 80
```

Next add the grafana chart as a dependency in `chart.yaml`

```yaml
dependencies:
  - name: grafana
    version: 9.4.3
    repository: https://grafana.github.io/helm-charts
    condition: global.grafana.enabled
```

Next we need to run the following command for helm to download the grafana helm chart.

```bash
helm dependency build
```

if the grafana version is updated, the following command needs to be ran so helm update the grafana chart in the `charts` folder

```bash
helm dependency update
```

Next, install the chart. The command below will create a namespace `grafana` and install the chart in that namespace.

```bash
helm install grafana . --create-namespace -n grafana
```

next add DNS entry to pi-hole for grafana

`grafana.nscubed.lan` to `192.168.1.81`

grafana is now available at `https://grafana.nscubed.lan`

#### Loki Setup

Now that Grafana is setup and accessible, let's setup Loki and Connect Grafana and Loki.

When setting up Loki, we don't need to create a new chart. As We are not going to sub chart the helm chart that is provided by the community. There is a values.yaml that we is provided as a starting point for Loki[^4]. Additionally there are example of configuration provided[^5].

[^4]: [Loki Docs-Scalable](https://grafana.com/docs/loki/latest/setup/install/helm/install-scalable/)
[^5]: [Loki Docs - Configuration](https://grafana.com/docs/loki/latest/configure/examples/configuration-examples/#1-local-configuration-exampleyaml)

Next we need to add a data source for Grafana so it can connect to Loki. When the Grafana chart is deployed, we should create a config map with the Datasoure for Loki.

following yaml will create a config map.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nscubed-grafana-datasource
  namespace: {{ .Values.namespace }}
{{- if .Values.grafana.sidecar.datasources.annotations }}
  annotations:
    {{- toYaml .Values.grafana.sidecar.datasources.annotations | nindent 4 }}
{{- end }}
  labels:
    app.kubernetes.io/managed-by: {{ .Release.Service }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/version: {{ template "grafana.chartref" . }}
    app.kubernetes.io/part-of: {{ template "grafana.name" . }}
    chart: {{ template "grafana.chartref" . }}
    release: {{ .Release.Name | quote }}
    heritage: {{ .Release.Service | quote }}
    grafana_datasource: "1"
data:
  datasource.yaml: |
    apiVersion: 1
    datasources:
    {{- range .Values.datasources }}
      - name: {{ .name }}
        type: {{ .type }}
        access: {{ .access }}
        orgId: {{ .orgId | default 1 }}
        uid: {{ .uid }}
        url: {{ .url }}
        basicAuth: {{ .basicAuth }}
        editable: {{ .editable | default false }}
    {{- end }}

```

#### Prometheus Setup

Prometheus community has helm charts that are available[^6]. There are lots of examples.

Install the following Helm Charts

1. Prometheus Operator CRDs[^7]

[^6]:[Prometheus-Community Helm Charts](https://github.com/prometheus-community/helm-charts/tree/main)
[^7]:[Prometheus Operator CRDs - Helm Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-operator-crds)
