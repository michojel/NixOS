```
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
```
