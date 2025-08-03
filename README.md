# Overview <!-- omit from toc -->

This repository has scripts, notes and other items to help setup a HomeLab.

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [How to Navigate the Repository Folders](#how-to-navigate-the-repository-folders)
- [Technologies Used](#technologies-used)

## Prerequisites

- [x] Docker Desktop

## Getting Started

1. Download the Repository
2. Create a folder certs

    ```bash
    sudo mkdir /home/certs
    ```

3. Grant your user permissions to the folder since it was created using `sudo`

   ```bash
   cd /home
   sudo chwon -R <user>:<group> certs
   ```

    For Example: my user is named `neil` and in a group named `neil`

    ```bash
    sudo chown -R neil:neil certs
    ```

4. Open the folder using VSCode
5. Build and Open in DevContainer

## How to Navigate the Repository Folders

`Docs` - documentation
`Journal` - markdown files with Thoughts, Notes and struggles encountered.
`Scripts` - Powershell and Bash scripts for performing various tasks.

## Technologies Used

- Docker
- PowerShell
- DevContainers
- Bash
- Hyper-V
- Kubernetes
- Cilium
- Cert Manager
- OpenSSL
