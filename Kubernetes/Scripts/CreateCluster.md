# Create Kubernetes Cluster Walkthrough

How to leverage the shell scripts to provision VMs using Hyper-V and configure each one.

## Walk Through

1. Create Virtual Machines
    Generate Cluster shell script will create
      1. One control plane VM
      2. Two worker node VMs
      3. It will add the SSH public key to each VM.

   ```bash
    ./generateCluster.sh
   ```

2. Disable password for when `sudo` is used.
    * This file will be removed when setup of the VMs is complete.
    1. Login into each VM using SSH
    2. switch to root via `sudo -i`
    3. execute the following command to disable password requirement when using sudo

        ```bash
        echo "neil ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/neil
        ```

3. Setup SSH

    ```bash
      ./setupSSH.sh -i "192.168.1.68"
      ./setupSSH.sh -i "192.168.1.69"
      ./setupSSH.sh -i "192.168.1.71"
    ```

4. Initialize the VM
   Setup Cluster shell script will
   1. Update Packages (apt / apt-get)
   2. Install Nano (text editor)
   3. Install Linux integration utilities.
   4. Lastly, it will reboot the VM

   ```bash
   ./setupCluster.sh
   ```
