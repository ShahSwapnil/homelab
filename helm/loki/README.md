# Loki

## Template

```pwsh
helm template loki . -f values.yaml -n monitoring --output-dir rendered
```

## Install

```pwsh
helm install loki . -f values.yaml -n monitoring --render-subchart-notes
```

## Notes after Install

***********************************************************************
 Welcome to Grafana Loki
 Chart version: 6.46.0
 Chart Name: loki
 Loki version: 3.5.7
***********************************************************************

** Please be patient while the chart is being deployed **

Tip:

  Watch the deployment status using the command: kubectl get pods -w --namespace monitoring

If pods are taking too long to schedule make sure pod affinity can be fulfilled in the current cluster.

***********************************************************************
Installed components:
***********************************************************************
* gateway
* minio
* read
* write
* backend


***********************************************************************
Sending logs to Loki
***********************************************************************

Loki has been configured with a gateway (nginx) to support reads and writes from a single component.

You can send logs from inside the cluster using the cluster DNS:

http://loki-gateway.monitoring.svc.cluster.local/loki/api/v1/push

You can test to send data from outside the cluster by port-forwarding the gateway to your local machine:

  kubectl port-forward --namespace monitoring svc/loki-gateway 3100:80 &

And then using http://127.0.0.1:3100/loki/api/v1/push URL as shown below:

```
curl -H "Content-Type: application/json" -XPOST -s "http://127.0.0.1:3100/loki/api/v1/push"  \
--data-raw "{\"streams\": [{\"stream\": {\"job\": \"test\"}, \"values\": [[\"$(date +%s)000000000\", \"fizzbuzz\"]]}]}"
```

Then verify that Loki did receive the data using the following command:

```
curl "http://127.0.0.1:3100/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' | jq .data.result
```



***********************************************************************
Connecting Grafana to Loki
***********************************************************************

If Grafana operates within the cluster, you'll set up a new Loki datasource by utilizing the following URL:

http://loki-gateway.monitoring.svc.cluster.local/


MinIO can be accessed via port 9000 on the following DNS name from within your cluster:
loki-minio.monitoring.cluster.local

To access MinIO from localhost, run the below commands:

  1. export POD_NAME=$(kubectl get pods --namespace monitoring -l "release=loki" -o jsonpath="{.items[0].metadata.name}")

  2. kubectl port-forward $POD_NAME 9000 --namespace monitoring

Read more about port forwarding here: http://kubernetes.io/docs/user-guide/kubectl/kubectl_port-forward/

You can now access MinIO server on http://localhost:9000. Follow the below steps to connect to MinIO server with mc client:

  1. Download the MinIO mc client - https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart

  2. export MC_HOST_loki-minio-local=http://$(kubectl get secret --namespace monitoring loki-minio -o jsonpath="{.data.rootUser}" | base64 --decode):$(kubectl get secret --namespace monitoring loki-minio -o jsonpath="{.data.rootPassword}" | base64 --decode)@localhost:9000

  3. mc ls loki-minio-local


```bash
$(kubectl get secret --namespace monitoring loki-minio -o jsonpath="{.data.rootUser}" | base64 --decode):$(kubectl get secret --namespace monitoring loki-minio -o jsonpath="{.data.rootPassword}" | base64 --decode
```

```pwsh
kubectl get secret --namespace monitoring loki-minio -o jsonpath="{.data.rootUser}" | Foreach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
kubectl get secret --namespace monitoring loki-minio -o jsonpath="{.data.rootPassword}" | Foreach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```
