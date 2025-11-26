# Getting Started <!-- omit in toc -->

Setting up the Homelab now that Ubuntu ISO has been downloaded and Virtual Machines specifications have been determined. 

Next Steps, [Setup Kubernetes](setup-kubernetes.md)

- [Create VMs](#create-vms)
- [Setup SSH](#setup-ssh)
  - [Setup SSH to use ssh-key](#setup-ssh-to-use-ssh-key)
  - [Setup SSH to use Names instead of IP Address](#setup-ssh-to-use-names-instead-of-ip-address)
- [Linux Integration Services](#linux-integration-services)


## Create VMs

Executing the following command from the scripts folder will create the Virtual Machines. 

I created `Create-K8sCluster.ps1` to execute the following commands. 

1. Create a VM for Control Plane'
   ```pwsh
    .\Create-VM.ps1 -VMName "nsc-k8s-cp-01" -MacAddress "00155D00C70A" -RAM 5000 -HDSizeGB 40
   ```
2. Create a VM for Worker Node #1
   ```pwsh
   .\Create-VM.ps1 -VMName "nsc-k8s-wn-01" -MacAddress "00155D00C70C" -RAM 44000 -HDSizeGB 50 -SecondHDSizeGB 350 
   ```

3. Create a VM for Worker Node #2
    ```pwsh
    .\Create-VM.ps1 -VMName "nsc-k8s-wn-02" -MacAddress "00155D00C70D" -RAM 44000 -HDSizeGB 50 -SecondHDSizeGB 350
    ```

4. Once the VMs have been created, turn them on and start the Ubuntu Installation. Follow the prompts on the screen to finish installing ubuntu and restarted. Be sure to install the following during installation
   1. OpenSSH Server

## Setup SSH

Next we want to setup SSH so we can copy files from the host and back. 

1. Verify the Service Status
   ```bash
    sudo systemctl status ssh
   ```
2. if it's not active, start it
   ```bash
    sudo systemctl start ssh
   ```
3. Check the Firewall to allow SSH traffic on port 22
   ```bash
    sudo ufw status
    sudo ufw allow ssh
    sudo ufw enable
   ```

### Setup SSH to use ssh-key

On the Host execute the following commands. Follow the prompts and enter your password when asked.

```bash
ssh-copy-id <user>@<ip_adddress>
```

to remove existing known hosts. 
```pwsh
ssh-keygen -R 192.168.1.69
ssh-keygen -R 192.168.1.71
ssh-keygen -R 192.168.1.72
```

```pwsh
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | ssh neil@192.168.1.69 "cat >> .ssh/authorized_keys"
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | ssh neil@192.168.1.71 "cat >> .ssh/authorized_keys"
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | ssh neil@192.168.1.72 "cat >> .ssh/authorized_keys"
```

### Setup SSH to use Names instead of IP Address

```pwsh
code %USERPROFILE%\.ssh\config
```

For each Virtual Machine, add a block defining the IP address and other information

```text
Host <Name>
    HostName <ip_address>
    User <user>
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

Now you can ssh into this vm using the following command

```pwsh
ssh <name>
```

For Example: 

```text
Host k8s-cp
    HostName 192.168.1.69
    User neil
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

so I can 
```pwsh
ssh k8s-cp
```

## Linux Integration Services

1. Run the following command and reboot the system. This installs Linux Integration Services. Which allow the Guest OS to return information to the Host OS.  

    ```bash
    sudo apt-get update
    sudo apt -y install linux-virtual linux-cloud-tools-virtual linux-tools-virtual
    sudo reboot
    ```

    once the VMs have reboot, we can connect via SSH now and don't have to log into the VMs. 
    Now using the Hyper-V Manager you can determine the IP address of all the VMs in case that was forgotten. 
