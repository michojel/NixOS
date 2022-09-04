#!/usr/bin/env bash

set -euo pipefail
set -x

sudo wipefs -a "/dev/nvme0n1"

i=0
sudo parted "/dev/nvme0n1" -- mklabel gpt

set -x
sudo parted --align optimal "/dev/nvme0n1" -- mkpart ESP fat32 1MiB 512MiB
i=$((i+1))
sudo mkfs.fat -F 32 -n EFI "/dev/nvme0n1p$i"
sudo parted --align optimal "/dev/nvme0n1" -- set $i esp on

sudo parted --align optimal "/dev/nvme0n1" -- mkpart primary linux-swap 512MiB 66048MiB
i=$((i+1))
sudo mkswap -L swap "/dev/nvme0n1p$i"

sudo parted --align optimal "/dev/nvme0n1" -- mkpart primary  66048MiB 100%
