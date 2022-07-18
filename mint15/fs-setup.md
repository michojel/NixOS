## Filesystem setup on mint15

### Partitions

    disk=/dev/nvme0n1
    sudo parted "$disk" -- mklabel gpt
    i=0
    sudo parted "$disk" -- mkpart primary 512MiB 100%
    i=$((i+1))
    #sudo parted "$disk" -- mkpart primary linux-swap -8GiB 100%
    #i=$((i+1))
    sudo parted "$disk" -- mkpart ESP fat32 1MiB 512MiB
    i=$((i+1))
    sudo parted "$disk" -- set $i esp on
    sudo mkfs.fat -F 32 -n EFI "${disk}p$i"

### ZFS Pool

    sudo zpool create \
      -o ashift=12 \
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
      nvme0n1p1

### ZFS Volumes

    zfs create -o mountpoint=none rpool/local
    zfs create -o canmount=on -o mountpoint=/nix -o atime=off                               rpool/local/nix
    zfs create -o canmount=on -o mountpoint=none -o refreservation=1G                       rpool/local/reserved
    zfs create -o canmount=on -o mountpoint=/tmp -o sync=disabled     -o normalization=none rpool/local/tmp

    zfs create -o mountpoint=none -o com.sun:auto-snapshot=true rpool/system
    zfs create -o canmount=on     -o mountpoint=/               rpool/system/root
    zfs create -o canmount=on     -o mountpoint=/mnt/nixos      rpool/system/nixos

    zfs create -o mountpoint=none -o com.sun:auto-snapshot=true rpool/user
    zfs create -o canmount=on -o mountpoint=/root               rpool/user/root
    zfs create -o canmount=on -o mountpoint=/home               rpool/user/home
    zfs create -o canmount=on -o mountpoint=/home/miminar       rpool/user/home/miminar
