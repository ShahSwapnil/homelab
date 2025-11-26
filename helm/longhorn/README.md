# Longhorn Storage

Setup Storage for Applications

## Setup the Virtual Disks + Virtual Machines

1. Create a virtual disk 350 GB
2. Turn off the wn-01 vm
3. attached the virtual disk
4. Create a second virtual disk 350 GB
5. Turn off the wn-02 vm
6. attach the virtual disk

## Install Longhorn

```pwsh
# Using Helm (assuming you have Helm installed)
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.10.1
```

## Format and Mount the Virtual Disks

Determine the Disk Name

```bash
lsblk
```

Format the disk
```bash
sudo mkfs.ext4 -F /dev/<DISK_NAME>
```

Create a directory for mounting
```bash
sudo mkdir -p /mnt/longhorn-storage
```

Copy the output
```bash
DISK_UUID=$(sudo blkid -s UUID -o value /dev/sdb)
echo "UUID=$DISK_UUID /mnt/longhorn-storage ext4 defaults 0 2"
```

paste the output from the above as the last line in fstab
```bash
sudo nano /etc/fstab
```

Restart Daemon
```bash
sudo systemctl daemon-reload
```

Mount the disk using the new fstab entry.
```bash
sudo mount -a
```

Verify
```bash
df -h /mnt/longhorn-storage
```

## Add Disks to Nodes in Longhorn UI

Node > edit Node and Disks
