#!/usr/bin/env bash

set -euo pipefail
set -x 


disk=/dev/nvme0n1p1

sudo wipefs -a "$disk"
# simple wipefs is not enough to get rid of an zfs pool
sudo dd if=/dev/zero of="$disk" status=progress bs=1MiB

sudo zpool create -f \
  -o autotrim=on \
  -R /mnt \
  -O canmount=off \
  -O mountpoint=none \
  -O acltype=posixacl \
  -O compression=zstd \
  -O dnodesize=auto \
  -O normalization=formD \
  -O relatime=on \
  -O xattr=sa \
  -O encryption=aes-256-gcm \
  -O keylocation=prompt \
  -O keyformat=passphrase \
  rpool \
  "$disk"

sudo zfs create -o refreservation=1G -o mountpoint=none rpool/reserved

sudo zfs create -o canmount=off -o mountpoint=none                                                    rpool/system
sudo zfs create -o canmount=on  -o mountpoint=/                       -o com.sun:auto-snapshot=true   rpool/system/root
sudo zfs create -o canmount=on  -o mountpoint=/mnt/nixos              -o com.sun:auto-snapshot=true   rpool/system/nixos
sudo zfs create -o canmount=off -o mountpoint=none                    -o com.sun:auto-snapshot=false  rpool/local
sudo zfs create -o canmount=on  -o mountpoint=/nix -o atime=off                                       rpool/local/nix
sudo zfs create -o canmount=on  -o mountpoint=/tmp                                                    rpool/local/tmp
sudo zfs create -o canmount=off -o mountpoint=none                                                    rpool/local/containers
sudo zfs create -o canmount=on  -o mountpoint=/var/lib/docker                                         rpool/local/containers/docker
sudo zfs create -o canmount=off -o mountpoint=none                                                    rpool/user
sudo zfs create -o canmount=on  -o mountpoint=/home                   -o com.sun:auto-snapshot=true   rpool/user/home
sudo zfs create -o canmount=on  -o mountpoint=/home/miminar           -o com.sun:auto-snapshot=true   rpool/user/home/miminar
sudo zfs create -o canmount=on  -o mountpoint=/home/miminar/Audio     -o com.sun:auto-snapshot=true -o quota=256G   rpool/user/home/miminar/Audio
sudo zfs create -o canmount=on  -o mountpoint=/home/miminar/Video     -o com.sun:auto-snapshot=true -o quota=512G   rpool/user/home/miminar/Video
sudo zfs create -o canmount=on  -o mountpoint=/root                   -o com.sun:auto-snapshot=true   rpool/user/root
