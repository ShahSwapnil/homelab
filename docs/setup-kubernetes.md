# Kubernetes Setup <!-- omit in toc -->

[Kubernetes Docs - Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

- [Prerequisite](#prerequisite)
  - [Check OS Version](#check-os-version)
  - [Verify MAC Address and product\_uuid are unique](#verify-mac-address-and-product_uuid-are-unique)
  - [Check Network Adapters](#check-network-adapters)
  - [Check Ports](#check-ports)
    - [Control Plane](#control-plane)
    - [Worker Node(s)](#worker-nodes)
  - [Swap Configuration](#swap-configuration)
  - [Container Runtime](#container-runtime)
    - [Enable IPv4 packet forwarding](#enable-ipv4-packet-forwarding)
    - [Install](#install)
    - [Configure the `systemd` cgroup driver](#configure-the-systemd-cgroup-driver)
- [Install kubeadm, kubelet and kubectl](#install-kubeadm-kubelet-and-kubectl)
- [Create Cluster](#create-cluster)
- [Additional Tools](#additional-tools)

Next Steps: [Cilium](../helm/cilium/README.md)

## Prerequisite

### Check OS Version 

Ubuntu LTS 24.04 is supported

### Verify MAC Address and product_uuid are unique

MAC Address are unique since we set them up that way

### Check Network Adapters

Only have one network adapter

### Check Ports

Check [Kubernetes Docs - Required Ports](https://kubernetes.io/docs/reference/networking/ports-and-protocols/)
   ```bash
   nc 127.0.0.1 6443 -zv -w 2
   ```
   - `nc` - NetCat utility
   - `127.0.0.1` - Target IP Address: This is the localhost IP address. The command is checking a service running on the same machine the command is executed on.
   - `6443` - The target port
   - `-z` - Zero-I/O mode: Tells `nc` to just scan for listening daemons and not try to send any data. It simply checks if the port is open and then immediately exits.
   - `-v` - Verbose mode
   - `-w 2` - Timeout

#### Control Plane

1. copy the `check-ports-cp.sh` to control plane, using 
    ```pwsh
    scp .\scripts\check-ports-cp.sh k8s-cp:~
    ```
2. Change the permissions on the script to allow it to execute.
    ```pwsh
    chmod +x check-ports-cp.sh
    ```
3. Run the script
    ```pwsh
    ./check-ports-cp.sh
    ```

#### Worker Node(s)
1. copy the `check-ports-wn.sh` to control plane, using 
      ```pwsh
      scp .\scripts\check-ports-wn.sh k8s-cp:~
      ```
2. Change the permissions on the script to allow it to execute.
      ```pwsh
      chmod +x check-ports-wn.sh
      ```
3. Run the script
      ```pwsh
      ./check-ports-wn.sh
      ```
### Swap Configuration
   1. Check the amount of free physical and swap memory
        There should be a row for Swap and it should have values. 
        ```bash
        free -h
        ```
   2. Disable Swap - Disable swap immediately
        ```bash
        sudo swapoff -a
        ```
   3. Check the amount of free physical and swap memory
        There should be a row for Swap and it should have zeros. 
        ```bash
        free -h
        ```
   4. edit `/etc/fstab` to make the change permanent
        ```bash
        sudo nano /etc/fstab
        ```
   5. Find the Swap Entry, Look for a line that contains the word `swap` in the fifth field (the file system type).
   6. Disable the Entry by adding a hash mark at the beginning of the line to comment it out. 
   7. reboot the VM
        ```bash
        sudo reboot
        ```
   8. Check the amount of free physical and swap memory. Swap memory should have zeros. 
    
### Container Runtime

[Kubernetes Docs - Container Runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)
[Kubernetes Docs - Containered](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd)
[Containerd - Getting Started](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)

#### Enable IPv4 packet forwarding

1. Run the following command to manually enable IPv4 packet forwarding
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
```
2. To Apply the config
```bash
sudo sysctl --system
```

3. Verify IPv4 packet forwarding setting is set appropriately
```bash
sysctl net.ipv4.ip_forward
```

#### Install

To install containerd, runc and CNI plugins 

1. copy the `setup-container-runtime.sh` to control plane, using 
    ```pwsh
    scp .\scripts\setup-container-runtime.sh k8s-cp:~
    ```
2. Change the permissions on the script to allow it to execute.
    ```pwsh
    chmod +x setup-container-runtime.sh
    ```
3. Run the script
    ```pwsh
    sudo ./setup-container-runtime.sh.sh
    ```

#### Configure the `systemd` cgroup driver

1. check if cgroup v2 is enabled
```bash
stat -f -c %T /sys/fs/cgroup
```

cgroup2fs - Cgroup v2 - Confirmed

2. edit the config.toml 
```bash
sudo nano /etc/containerd/config.toml
```

3. Locate `[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]`
   1. Set `SystemdCgroup` to true, `SystemdCgroup = true`

4. Restart Containerd

```bash
sudo systemctl restart containerd
```

## Install kubeadm, kubelet and kubectl

[Kubernetes Docs](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)

1. Update the apt package index and install packages needed to use the Kubernetes apt repository:

```bash
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

2. Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL:

```bash
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

3. Add the appropriate Kubernetes apt repository. 

```bash
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

4. Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:
```bash

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

5. Enable the kubelet service before running kubeadm:

```bash
sudo systemctl enable --now kubelet
```

## Create Cluster

1. Rename the node appropriately.
```bash
sudo hostnamectl set-hostname nsc-k8s-cp-01
sudo hostnamectl set-hostname nsc-k8s-wn-01
sudo hostnamectl set-hostname nsc-k8s-wn-02
```

2. Initialize Control Plane without Kube Proxy [^1]

```bash
sudo ufw allow 6443/tcp
sudo ufw reload
kubeadm init --skip-phases=addon/kube-proxy --config kubeadm-config.yaml
```

2. Copy the kube config to host, Before you can copy the file. You need to copy and setup permissions
    ```bash
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    ```
3. Use the `scp` command to copy to the file to host
   ```bash
   scp neil@k8s-cp:~/.kube/config C:\Users\swapn\.kube\config
   ```
4. `kubectl` should now work on the host. 
5. Run the join command to add the worker nodes to the cluster
6. Run the following command to apply a taint to each of the nodes
   ```bash
   kubectl taint nodes worker-node-2 node.cilium.io/agent-not-ready:NoExecute
   ```
7. Run `kubectl get nodes` to display all the nodes
8. Add `cluster` label to all the nodes
    ```bash
    kubectl label nodes nsc-k8s-cp-01 cluster=nsc-k8s-dev
    kubectl label nodes nsc-k8s-wn-01 cluster=nsc-k8s-dev
    kubectl label nodes nsc-k8s-wn-02 cluster=nsc-k8s-dev
    ```

## Additional Tools

Install Helm and k9s to make interacting with the cluster easier. 

[K9s Docs - Install](https://k9scli.io/topics/install/)
[Helm Docs - Install Helm](https://helm.sh/docs/intro/install)


[^1]: [Kube Proxy Replacement](https://cilium.io/use-cases/kube-proxy/)
