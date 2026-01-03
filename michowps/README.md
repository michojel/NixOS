# michowps

## Bootstrap

1. Go to [wedos serverhosting
   michowps](https://client.wedos.com/serverhosting/detail.html?id=27671&flag=f_virtual&exec=virtual_iso_attach&exh=326b1862dae83ab74747).

1. Find out the latest NixOS ISO image URL at
   [releases.nixos.org](https://releases.nixos.org/?prefix=nixos).

1. Go to [ISO
   management](https://client.wedos.com/serverhosting/iso-management.html?id=27671)
   and download the image there.

1. Go to [serverhosting](https://client.wedos.com/serverhosting/detail.html?id=27671) and turn
   the VM on.

1. Connect to VNC with `vncviewer  27671.vm71.wedos.net:37671`

1. Once booted, become root: `sudo su`

1. Configure basic networking:

    ```sh
    ip addr add 31.31.73.95/24 dev ens3
    ip route add default via 31.31.73.1
    echo "nameserver 46.28.108.2" >>/etc/resolv.conf
    ```

1. Fetch authorized keys:

    ```sh
    cd /root/.ssh
    curl -L -o authorized_keys https://github.com/michojel.keys
    ```

1. Connect via SSH:

    ```
    ssh -4 root@michojel.cz
    ```

1. Copy live configuration:

    ```sh
    scp live-nixos-configuration.nix root@michojel.cz:/etc/nixos/configuration.nix
    ```

1. Re-configure the preos in-memory OS:

    ```sh
    nixos-rebuild switch
    ```

1. Copy format.sh script:

    ```sh
    scp format.sh root@michojel.cz:/root/
    ```

1. Destroy previous zpool:

    ```sh
    # import without mounting
    zpool import -N -R /mnt -f zroot
    zpool destroy zroot
    ```

    NOTE: to do some changes to an existing pool:

    ```sh
    zpool import -l -R /mnt -f zroot
    mount /dev/vda1 /mnt/boot
    swapon /dev/vda2
    nixos-enter --root /mnt
    ```

1. Format the disk:

    ```sh
    bash format.sh
    ```

1. Mount boot partition:

    ```sh
    mkdir /mnt/boot
    mount /dev/vda1 /mnt/boot
    # clean it up:
    rm -rfv /mnt/boot/*
    ```

1. Enable swap:

    ```sh
    swapon /dev/vda2
    ```

1. Copy configuration:

    ```sh
    # on michowps
    mkdir /mnt/etc/nixos
    ```

    Locally:

    ```sh
    scp /home/miminar/.backup/michojel.cz/2025-12-25-mnt-etc-nixos/*.nix  root@michojel.cz:/mnt/etc/nixos/
    ```

1. Kick-off the installation:

    ```sh
    nixos-install --root /mnt
    ```

1. Setup authorized\_keys:

    ```sh
    mkdir -m 0700 /mnt/home/michojel/.ssh
    cd /mnt/home/michojel/.ssh
    cp ~/.ssh/authorized_keys ./
    chown -R 1000:100 ./
    ```

1. Shutdown: `shutdown -h now`

1. Unmount the ISO at
   [serverhosting](https://client.wedos.com/serverhosting/detail.html?id=27671)
   and start the VM.

1. Connect again to the VNC and input the password to mount the zpool.

1. Once booted, copy the nix store to its own ZFS volume:

    ```sh
    mount -t zfs zroot/local/nix /mnt/nix
    rsync -av /nix /mnt/nix
    umount /mnt/nix
    mount -t zfs zroot/local/nix /nix
    ```

1. In /etc/nixos/hardware-configuration.nix, uncomment `/nix` mount:

    ```nix
      fileSystems."/nix" =
        {
          device = "zroot/local/nix";
          fsType = "zfs";
        };
    ```

    **NOTE**: no `options = ["zfsutil"];` thanks to the `mountpoint=legacy`
    property on the volume.

    And rebuild: `nixos-rebuild switch`
