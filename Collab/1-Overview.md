# Overview <!-- omit in toc -->

Initial Kick off conversation about HomeLab.

- [Questions and Answers](#questions-and-answers)
  - [What is a HomeLab?](#what-is-a-homelab)
  - [Why a HomeLab?](#why-a-homelab)
  - [What are Goals for setting up a HomeLab?](#what-are-goals-for-setting-up-a-homelab)
  - [What is on the Learning Agenda](#what-is-on-the-learning-agenda)
  - [Where do we start?](#where-do-we-start)

## Questions and Answers

### What is a HomeLab?

A Homelab is exactly what it sounds like: it's a personal environment or a digital playground that you set up in your own home. It can be a simple spare desktop, or a dedicated server rack in the closet.

### Why a HomeLab?

For me the HomeLab is for learning, building MVPs, Proof of Concepts as well have things that I need at home. For Example, Use Pi-Hole to block ads on all of our devices. Applications I create for my family.

I want to have an environment setup that will allow me to just working on POCs instead of setting up infrastructure each and everytime I want to create a new project.

### What are Goals for setting up a HomeLab?

1. Kubernetes up and running, so I can spin up various workloads
2. Observability Stack for Logs, Metrics and Traces ready to go, so when I start working on a new application I don't have to keep setting it up over and over again.

Wait you can use automation to setup all the stuff you need every time you start up a new project. Sure but I have wanted to learn about the ecosystem for kubernetes and from an software engineer stand point - understand the infrastructure is 1/2 the battle when you are debugging and working through an issue.

### What is on the Learning Agenda

In order to setup a Kubernetes Cluster, there is a whole host to techonologies I need to learn or refresh some.

1. Powershell Scripting
   1. Create Virtual Machines in Hyper-V.
1. Linux OS - clearly not in it's entirety
   1. Understand group permissions
   1. Understand pre-requisites for k8s [^1]
1. Bash Scripting to install pre-requisites for K8s
1. Helm [^2] - Package manager for K8s
1. CNI - Cilium [^3] - Service Mesh
1. Open Telemetry (OTEL)
1. Grafana Stack (Grafana - Loki - Tempo - Prometheus)
1. Harbor - Private Container Registry
1. Longhorn
1. k9s

and the list goes on and on.

The idea is to explore each of these enough to be able to get to my end goal of having an environment setup that I can quickly start to prototype and learn technologies we use at work.

[^1]: [Kubernetes Documentation - Before you begin](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin)
[^2]: [Helm Documentation](https://helm.sh/)
[^3]: [Cilium Documentation](https://docs.cilium.io/en/stable/)

### Where do we start? 
