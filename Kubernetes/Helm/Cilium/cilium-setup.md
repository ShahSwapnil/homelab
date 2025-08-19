# Cilium

Overview of the features enabled in Cilium.

## Features

- KubeProxyReplacement

## Helm Command

Enables KubeProxyReplacement and allows all nodes to get to a ready state including control plane.

```bash
helm install cilium cilium/cilium --version 1.18.0 \
    --namespace kube-system \
    --set kubeProxyReplacement=true \
    --set k8sServiceHost=192.168.1.68 \
    --set k8sServicePort=6443
```

Layer 2 Announcements make services visible and reachable on the local area network (LAN).

```bash
helm upgrade cilium cilium/cilium --version 1.18.0 \
    --namespace kube-system \
    --reuse-values \
    --set l2announcements.enabled=true \
    --set k8sClientRateLimit.qps=33 \
    --set k8sClientRateLimit.burst=45 \
    --set kubeProxyReplacement=true \
    --set k8sServiceHost=192.168.1.68 \
    --set k8sServicePort=6443 \
    --set gatewayAPI.enabled=true
```

The DaemonSet for Cilium needs to be restarted so the new values will be applied.

```bash
  kubectl rollout restart ds/cilium -n kube-system
```

Apply the manifest in `/Kubernetes/Helm/Manifests/nginx-test.yaml

Navigate to the `Manifest` folder and run the following command

```bash
  kubectl apply -f ./nginx-test.yaml
```

The manifest contains:

- Service named `nginx-test-service` of type `LoadBalancer` and can be reached on port 80.
- Deployment that spins up a nginx web server and listens on port 80.

Execute the following command to get the IP for `nginx-test-service`

```bash
  kubectl get svc
```

`nginx-test-service` only has a CLUSTER-IP and `External-IP` is pending. This means the service cannot be reached from outside the cluster. If you want to reach the service, you would have to create a debug container and exec into it. That's not really very help.

Let's create two things

- IP Pool, so cilium knows the range of IPs it can assign
- L2 Announcement Policy, this tells Cilium to announce the IPs so they are reachable.

Install the Helm chart `ConfigureCilium`

Now, re-run the kubectl command get to services.

This time `nginx-test-service` has an external IP! Open up a web browser and navigate to the IP address.

Now let's enable Hubble. Hubble provides Observability into our cluster. We will setup LGTM stack later but for now, we still need observability into our cluster/nodes.

```bash
helm upgrade cilium cilium/cilium --version 1.18.0 \
   --namespace kube-system \
   --reuse-values \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true
```

setup Gateway API Support

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml
```

```bash
helm upgrade cilium cilium/cilium --version 1.18.1 \
    --namespace kube-system \
    --reuse-values \
    --set gatewayAPI.enabled=true
```

```bash
kubectl -n kube-system rollout restart deployment/cilium-operator
```

```bash
kubectl -n kube-system rollout restart ds/cilium
```
