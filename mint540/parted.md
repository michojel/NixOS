```
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
```
