#!/usr/bin/env bash

set -euo pipefail

zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O encryption=on -O keylocation=prompt -O keyformat=passphrase \
    -O acltype=posixacl -O xattr=sa -O dnodesize=auto \
    -O compression=lz4 \
    -O normalization=formD \
    -O relatime=on \
    -O canmount=off \
    -O com.sun:auto-snapshot=false \
    -R /mnt \
    zroot /dev/vda3

snapon=( -o com.sun:auto-snapshot=true )
snapoff=( -o com.sun:auto-snapshot=false )

zfs create -o canmount=off -o refreservation=4G  -o mountpoint=none       zroot/reserved
zfs create -o canmount=off                                                zroot/local
zfs create -o canmount=off                                                zroot/local/containers
zfs create -o canmount=on  -o mountpoint=/var/lib/docker                  zroot/local/containers/docker
# when mounted directly to /nix, the OS will not boot
# nix store must be moved to its own volume after the initial bootstrap
zfs create -o canmount=on  -o mountpoint=legacy                           zroot/local/nix
zfs create -o canmount=on  -o mountpoint=/tmp -o sync=disabled            zroot/local/tmp
zfs create -o canmount=off                                "${snapon[@]}"  zroot/system
zfs create -o canmount=on  -o mountpoint=/                                zroot/system/root
zfs create -o canmount=on  -o mountpoint=/etc/nixos.d                     zroot/system/nixos
zfs create -o canmount=off                                                zroot/system/var
zfs create -o canmount=off                                                zroot/system/var/lib
zfs create -o canmount=on  -o mountpoint=/var/lib/private                 zroot/system/var/lib/private
zfs create -o canmount=on -o mountpoint=/var/db                           zroot/system/var/db
zfs create -o canmount=off                                "${snapon[@]}"  zroot/user
zfs create -o canmount=on  -o mountpoint=/home                            zroot/user/home
zfs create -o canmount=on  -o mountpoint=/home/michojel                   zroot/user/home/michojel
zfs create -o canmount=on  -o mountpoint=/root                            zroot/user/root

chmod 0700 /mnt/var/lib/private /mnt/root /mnt/home/michojel
