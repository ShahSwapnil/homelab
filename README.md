# HomeLab <!-- omit in toc -->

Notes from when I setup the homelab, along with breadcrumbs for when I need to redo the work. 

Next Steps, [Getting Started](docs/getting-started.md)

- [Prerequisite](#prerequisite)
- [Hyper-V Setup](#hyper-v-setup)
  - [PiHole Server](#pihole-server)
  - [Control Plane](#control-plane)
  - [Worker Node](#worker-node)
- [Goals](#goals)
- [Documents](#documents)


## Prerequisite

1. [Download Ubuntu Server ISO](https://ubuntu.com/download/server) - Be sure to download the LTS

## Hyper-V Setup

Need to determine the size of our VMs

Total Resources

- 16 Cores
- 128 GB Ram
- 1 TB of Hard drive space

### PiHole Server

- 1 Processor
- 3 GB RAM

### Control Plane

- 2 Processors
- 5 GB RAM
- 40 GB Storage
- Mac Address: 00155D00C70A / IP Address: 192.168.1.69

### Worker Node

- 5 Processors
- 44 GB Ram
- 50 GB Storage
- 350 GB extra storage
- Mac Addresses: 00155D00C70C / 00155D00C70D
- IP Addresses: 
  - WN #1: 192.168.1.71
  - WN #2: 192.168.1.72

## Goals

When initially creating and setting up the cluster, the goal is to create scripts that allow us to automate the entire setup. 

- Look into Ansible for automating the entire K8s Cluster setup. Everything up from Getting started and Setup Kubernetes can be automated using Ansible. Since all three nodes need the same thing. 

## Documents

1. [Getting Started](docs/getting-started.md)
2. [Setup Kubernetes](docs/setup-kubernetes.md)
