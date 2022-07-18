## Filesystem setup on mint15

### Partitions


    set -euo pipefail
    set -x

    GiB16=17180MB

    sudo parted "/dev/sda" -- mklabel gpt
    i=0
    sudo parted --align optimal "/dev/sda" -- mkpart primary 512MiB -"$GiB16"
    i=$((i+1))
    sudo parted --align optimal "/dev/sda" -- mkpart primary linux-swap -"$GiB16" 100%
    i=$((i+1))
    sudo mkswap -L swap "/dev/sda$i"
    sudo parted --align optimal "/dev/sda" -- mkpart ESP fat32 1MiB 512MiB
    i=$((i+1))
    sudo parted --align optimal "/dev/sda" -- set $i esp on
    sudo mkfs.fat -F 32 -n EFI "/dev/sda$i"
    sudo parted --align optimal "/dev/sdb" -- mklabel gpt
    i=0
    sudo parted --align optimal "/dev/sdb" -- mkpart primary 1MiB 128GiB
    i=$((i+1))
    sudo mkfs.xfs -L containers "/dev/sdb$i"
    sudo parted --align optimal "/dev/sdb" -- mkpart primary 128GiB 100%
    i=$((i+1))

### ZFS Pools

    sudo zpool create \
      -o autotrim=on \
      -R /mnt \
      -O canmount=off \
      -O mountpoint=none \
      -O acltype=posixacl \
      -O compression=lz4 \
      -O dnodesize=auto \
      -O normalization=formD \
      -O relatime=on \
      -O xattr=sa \
      -O encryption=aes-256-gcm \
      -O keylocation=prompt \
      -O keyformat=passphrase \
      rpool \
      /dev/sda1

    sudo zpool create \
      -O canmount=off \
      -O mountpoint=none \
      -O acltype=posixacl \
      -O compression=lz4 \
      -O dnodesize=auto \
      -O normalization=formD \
      -O relatime=on \
      -O xattr=sa \
      -O encryption=aes-256-gcm \
      -O keylocation=prompt \
      -O keyformat=passphrase \
      datapool \
      /dev/sdb2

### ZFS Volumes

    sudo zfs create -o refreservation=1G -o mountpoint=none rpool/reserved
    sudo zfs create -o refreservation=1G -o mountpoint=none datapool/reserved

    sudo zfs create -o canmount=off -o mountpoint=none                                                    rpool/system
    sudo zfs create -o canmount=on  -o mountpoint=/                       -o com.sun:auto-snapshot=true   rpool/system/root
    sudo zfs create -o canmount=on  -o mountpoint=/mnt/nixos              -o com.sun:auto-snapshot=true   rpool/system/nixos
    sudo zfs create -o canmount=off -o mountpoint=none                    -o com.sun:auto-snapshot=false  rpool/local
    sudo zfs create -o canmount=on  -o mountpoint=/nix -o atime=off                                       rpool/local/nix
    sudo zfs create -o canmount=on  -o mountpoint=/tmp                                                    rpool/local/tmp
    sudo zfs create -o canmount=off -o mountpoint=none                                                    rpool/user
    sudo zfs create -o canmount=on  -o mountpoint=/home                   -o com.sun:auto-snapshot=true   rpool/user/home
    sudo zfs create -o canmount=on  -o mountpoint=/home/michojel          -o com.sun:auto-snapshot=true   rpool/user/home/michojel
    sudo zfs create -o canmount=on  -o mountpoint=/root                   -o com.sun:auto-snapshot=true   rpool/user/root
