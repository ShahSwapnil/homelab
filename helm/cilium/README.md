# Setup Cilium <!-- omit in toc -->

Notes from setting up Cilium

- [Helm](#helm)
  - [Kube Proxy Replacement](#kube-proxy-replacement)
  - [Setup Gateway API](#setup-gateway-api)
  - [Setup Hubble](#setup-hubble)
  - [Setup L2 Announcements](#setup-l2-announcements)
  - [IPSec Encryption](#ipsec-encryption)
  - [Observability Metrics](#observability-metrics)
  - [Install](#install)
    - [Final Command](#final-command)
  - [Template](#template)
  - [Uninstall](#uninstall)
- [References](#references)


## Helm 

1. Add the Helm Repo for Cilium
   ```bash
   helm repo add cilium https://helm.cilium.io/
   ```
2. Get the Values from the Helm chart
   ```pwsh
   helm show values cilium/cilium --version 1.18.4 | Out-File -FilePath ./values.yaml -Encoding UTF8
   ```
3. Render the helm chart
4. Install the Helm Chart


### Kube Proxy Replacement 

[Kube Proxy Replacement](https://cilium.io/use-cases/kube-proxy/)
[Cilium Docs - Kube Proxy Setup](https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/#kubeproxy-free)

Run the following command to install Cilium 

```pwsh
helm install cilium cilium/cilium --version 1.18.4 `
    --namespace kube-system `
    --set kubeProxyReplacement=true `
    --set k8sServiceHost=192.168.1.69 `
    --set k8sServicePort=6443
```

Verify KuberProxyReplacement is being recognized by Cilium

```pwsh
kubectl -n kube-system exec ds/cilium -- cilium-dbg status | Select-String KubeProxyReplacement
```

Execute the following command to watch the status of the pods. Alternatively you can switch over the K9s. 

```pwsh
kubectl -n kube-system get pods --watch
```

### Setup Gateway API

[Cilium Docs - Gateway API Support](https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/gateway-api/)

Connectivity to the Kubernetes cluster and all deployed services is currently unavailable. In order to resolve this, we need to setup a Gateway. Where all incoming traffic is routed to, very similar to Ingress. 

Install the following CRDs (copy the commands the documentation linked above)

```pwsh
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
```

Next Upgrade the Cilium install

```pwsh
helm upgrade cilium cilium/cilium --version 1.18.4 `
    --namespace kube-system `
    --reuse-values `
    --set gatewayAPI.enabled=true
```

Cilium Operator and DaemonSet need to be restarted 

```pwsh
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium
```

You can check the status using K9s, kubectl or cilium CLI, wait until all the pods are up and running. 

next a Gateway needs to be created. There is a simmple gateway manifest file in the manifest folder. 

```pwsh
kubectl apply -f .\manifest\gateway.yaml
```

How there should be a service that was automatically created and it's external IP is pending! 

In order to have Cilium assign an IP, we need to tell Cilium what ip addresses are available. We do this via IPPool. 

```pwsh
kubectl apply -f .\manifest\ippool.yaml
```

once this is manifest has been applied. You can take a look at the service that was created by the Gateway. 

and Finally, an HttpRoute needs to be added so the Gateway knows where to route the traffic. 

```pwsh
kubectl apply -f .\manifest\httproute.yaml
```

Update DNS entry to route nginx.nscubed.lan or whatever path you would like to the Gateway SVC. 

if the gateway acts up, roll the cilium operator and dameonset

```pwsh
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium
```

### Setup Hubble

```pwsh
helm upgrade cilium cilium/cilium --version 1.18.4 `
    --namespace kube-system `
    --reuse-values `
    --set hubble.relay.enabled=true `
    --set hubble.ui.enabled=true `
    --set hubble.tls.enabled=false
```

### Setup L2 Announcements

```pwsh
helm upgrade cilium cilium/cilium --version 1.18.4 `
    --namespace kube-system `
    --reuse-values `
    --set l2announcements.enabled=true `
    --set k8sClientRateLimit.qps=5 `
    --set k8sClientRateLimit.burst=10 
```

### IPSec Encryption

[Cilium Docs - IPsec Transparent Encryption](https://docs.cilium.io/en/stable/security/network/encryption-ipsec/#ipsec-transparent-encryption)

1. Generate the kubernetes secret that will be used for encryption. 
   ```pwsh
    cilium encrypt create-key --auth-algo rfc4106-gcm-aes
   ```
2. Enable Encryption in Cilium
   ```pwsh
   helm upgrade cilium cilium/cilium --version 1.18.4 `
    --namespace kube-system `
    --reuse-values `
    --set encryption.enabled=true `
    --set encryption.type=ipsec
    ```
3. Follow the steps outlined on [Cilium Docs - Validate the Setup](https://docs.cilium.io/en/stable/security/network/encryption-ipsec/#validate-the-setup)

#### Key Rotation

```bash
KEYID=$(kubectl get secret -n kube-system cilium-ipsec-keys -o go-template --template={{.data.keys}} | base64 -d | grep -oP "^\d+")
if [[ $KEYID -ge 15 ]]; then KEYID=0; fi
data=$(echo "{\"stringData\":{\"keys\":\"$((($KEYID+1)))+ "rfc4106\(gcm\(aes\)\)" $(dd if=/dev/urandom count=20 bs=1 2> /dev/null | xxd -p -c 64) 128\"}}")
kubectl patch secret -n kube-system cilium-ipsec-keys -p="${data}" -v=1
```

### Observability Metrics

```pwsh
helm upgrade cilium cilium/cilium --version 1.18.4 `
    --namespace kube-system `
    --reuse-values `
    --set prometheus.enabled=true `
    --set operator.prometheus.enabled=true `
    --set hubble.enabled=true `
    --set hubble.metrics.enableOpenMetrics=true `
    --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}"
```

### Install

#### Final Command

```pwsh
helm install cilium cilium/cilium --version 1.18.4 `
  --namespace kube-system `
  --set kubeProxyReplacement=true `
  --set k8sServiceHost=192.168.1.69 `
  --set k8sServicePort=6443 `  
  --set gatewayAPI.enabled=true `
  --set hubble.relay.enabled=true `
  --set hubble.ui.enabled=true `
  --set l2announcements.enabled=true `
  --set k8sClientRateLimit.qps=5 `
  --set k8sClientRateLimit.burst=10
```

### Template

```pwsh
helm template cilium cilium/cilium --version 1.18.4 `
  --namespace kube-system `
  --set kubeProxyReplacement=true `
  --set gatewayAPI.enabled=true `
  --set k8sServiceHost=192.168.1.69 `
  --set k8sServicePort=6443 `  
  --set hubble.relay.enabled=true `
  --set hubble.ui.enabled=true `
  --set l2announcements.enabled=true `
  --set k8sClientRateLimit.qps=5 `
  --set k8sClientRateLimit.burst=10 `
  --set nodePort.enabled=true `
  --set l7proxy=true `
  --output-dir rendered
```

### Uninstall


```pwsh
helm uninstall cilium --namespace kube-system
```

## References
https://docs.cilium.io/en/stable/observability/hubble/hubble-ui/#enable-the-hubble-ui
https://docs.cilium.io/en/stable/network/l2-announcements/#l2-announcements
https://docs.cilium.io/en/stable/network/lb-ipam/#cidrs-ranges-and-reserved-ips

