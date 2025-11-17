# Steps to Set Up a New Virtual Hard Disk on Ubuntu

This guide outlines the process of preparing and mounting a new virtual hard disk on an Ubuntu virtual machine.

-----

## 1. Identify the New Disk

First, you need to identify the new, unformatted disk. Use the `lsblk` command to list all block devices connected to your system. Look for a disk with no partitions and a size that matches your new virtual hard disk. It will likely be named something like `/dev/sdb` or `/dev/sdc`.

```bash
sudo lsblk
```

-----

## 2. Create a Filesystem

Once you've identified the disk, you need to format it with a filesystem. For most use cases, `ext4` is a great choice. **Make sure you replace `/dev/sdX` with the correct disk name you found in the previous step.**

```bash
sudo mkfs.ext4 /dev/sdX
```

-----

## 3. Create a Mount Point

Next, create a directory that will serve as the mount point for your new disk. A common practice is to use a directory like `/newdisk` or, in your case, `/longhorn`.

```bash
sudo mkdir /longhorn
```

-----

## 4. Mount the Disk

Now you can mount the new disk to the directory you just created.

```bash
sudo mount /dev/sdX /longhorn
```

-----

## 5. Make the Mount Persistent

To ensure the disk automatically mounts every time the system reboots, you need to add an entry to the `/etc/fstab` file. It's best to use the disk's UUID (Universally Unique Identifier) to do this, as the device name (`/dev/sdX`) can sometimes change.

First, find the UUID of your new disk:

```bash
sudo blkid /dev/sdX
```

Next, open the `/etc/fstab` file with a text editor.

```bash
sudo nano /etc/fstab
```

Add the following line to the end of the file, replacing the UUID with the one you just found:

```bash
UUID=<your-uuid> /longhorn ext4 defaults 0 0
```

Save the file and exit the editor. You can test the new entry by unmounting and remounting all entries in `/etc/fstab`:

```bash
sudo umount /longhorn
sudo mount -a
```

Your new virtual hard disk is now ready to use and will be available after every reboot.
