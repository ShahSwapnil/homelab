# Overview

Total Processors: 16

| Name | Processor Count | Memory | MacAddress | Hard Drive |IP Address|
|:-----|:---------------:|:-------|:----------:|:----------:|:--------:|
|nsc-prox-node-01|1|3GB|00:15:5D:00:C7:0B| 50 GB |192.168.1.70|
|nsc-k8s-cp-01|2|8GB|00:15:5D:00:C7:09| 100 GB |192.168.1.68|
|nsc-k8s-wn-01|5|32GB|00:15:5D:00:C7:0A| 100 GB |192.168.1.69|
|nsc-k8s-wn-02|5|32GB|00:15:5D:00:C7:0C| 100 GB |192.168.1.70|

Notes:

- 13 Cores for VM
- 3 Cores for PC
- 350 GB of SSD is spoken for. So that leaves about 650 GB. I need to figure out how to Break up 600 GB and provide that to K8s Cluster.
