# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports = [ /mnt/nixos/common/hardware-configuration.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "kvm-intel" "wacom" ];
  boot.extraModulePackages = [];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/52ac0dee-c9cf-4dbf-b82a-1032740d80f4";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/E364-7221";
      fsType = "vfat";
      options = [ "noatime" ];
    };

  fileSystems."/nix" =
    {
      device = "tank/minap50/nix";
      fsType = "zfs";
      options = [ "relatime" ];
    };

  fileSystems."/tmp" =
    {
      device = "tank/minap50/tmp";
      fsType = "zfs";
      options = [ "relatime" ];
    };

  fileSystems."/home" =
    {
      device = "encbig/home";
      fsType = "zfs";
      options = [ "relatime" ];
    };

  fileSystems."/mnt/nixos" =
    {
      device = "encbig/nixos";
      fsType = "zfs";
      options = [
        "relatime"
        "x-gvfs-hide"
      ];
    };

  fileSystems."/home/miminar/Pictures" =
    {
      device = "encdedup/home/miminar/pictures";
      fsType = "zfs";
      options = [
        "relatime"
        "x-systemd.requires=mnt-nixos.mount"
        "x-systemd.after=mnt-nixos.mount"
        "x-gvfs-hide"
      ];
    };

  fileSystems."/home/miminar/Audio" =
    {
      device = "encuncomp/home/miminar/audio";
      fsType = "zfs";
      options = [
        "relatime"
        "x-systemd.requires=mnt-nixos.mount"
        "x-systemd.after=mnt-nixos.mount"
        "x-gvfs-hide"
      ];
    };

  #  fileSystems."/var/lib/libvirt" =
  #    { device = "enctank/libvirt";
  #      fsType = "zfs";
  #      options = ["relatime"];
  #    };
  #
  #  fileSystems."/var/vmshare" =
  #    { device = "enctank/vmshare";
  #      fsType = "zfs";
  #      options = ["relatime"];
  #    };
  #
  #  fileSystems."/var/lib/libvirt/images" =
  #    { device = "enctank/libvirt/images";
  #      fsType = "zfs";
  #      options = ["noatime"];
  #};

  fileSystems."/var/lib/docker" =
    {
      device = "/dev/disk/by-uuid/3bb39c50-c8f4-4355-bc5a-c836c12de945";
      fsType = "xfs";
      options = [ "noatime" "discard" ];
    };

  swapDevices =
    [
      { device = "/dev/disk/by-uuid/602391ae-1e7d-4ef1-9c40-4a30fb85ccfd"; }
    ];

  nix.maxJobs = lib.mkDefault 8;

  hardware = {
    # Manage Optimus hybrid Nvidia video cards
    # TODO: make it work
    #bumblebee.enable = true;
    opengl.driSupport32Bit = true;
    trackpoint.enable = true;
    bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
      powerOnBoot = false;
    };
    #steam-hardware.enable = true;
  };
}
