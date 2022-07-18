# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "wacom" "v4l2loopback" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "rpool/system/root";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/root" = {
    device = "rpool/user/root";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/nix" = {
    device = "rpool/local/nix";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/mnt/nixos" = {
    device = "rpool/system/nixos";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/tmp" = {
    device = "rpool/local/tmp";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/home" = {
    device = "rpool/user/home";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/home/michojel" = {
    device = "rpool/user/home/michojel";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EB80-C328";
    fsType = "vfat";
    options = [ "noatime" ];
  };

  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-uuid/995adea5-92c7-4ee6-8651-c6c206a7e8fa";
    fsType = "xfs";
  };

  fileSystems."/home/michojel/Audio" = {
    device = "datapool/user/home/michojel/audio";
    fsType = "zfs";
    options = [
      "zfsutil"
      "x-systemd.requires=mnt-nixos.mount"
      "x-gvfs-hide"
    ];
  };

  fileSystems."/home/michojel/Documents" = {
    device = "datapool/user/home/michojel/documents";
    fsType = "zfs";
    options = [
      "zfsutil"
      "x-systemd.requires=mnt-nixos.mount"
      "x-gvfs-hise"
    ];
  };

  fileSystems."/home/michojel/Downloads" = {
    device = "datapool/user/home/michojel/downloads";
    fsType = "zfs";
    options = [
      "zfsutil"
      "x-systemd.requires=mnt-nixos.mount"
      "x-gvfs-hise"
    ];
  };

  fileSystems."/home/michojel/Pictures" = {
    device = "datapool/user/home/michojel/pictures";
    fsType = "zfs";
    options = [
      "zfsutil"
      "x-systemd.requires=mnt-nixos.mount"
      "x-gvfs-hise"
    ];
  };

  fileSystems."/home/michojel/VirtualBox VMs" = {
    device = "datapool/user/home/michojel/vbox-vms";
    fsType = "zfs";
    options = [
      "zfsutil"
      "x-systemd.requires=mnt-nixos.mount"
      "x-gvfs-hise"
    ];
  };

  fileSystems."/home/michojel/Video" = {
    device = "datapool/user/home/michojel/video";
    fsType = "zfs";
    options = [
      "zfsutil"
      "x-systemd.requires=mnt-nixos.mount"
      "x-gvfs-hise"
    ];
  };

  swapDevices =
    [{
      device = "/dev/disk/by-id/ata-SAMSUNG_MZ7TE256HMHP-000L7_S1K7NSAF970717-part2";
      randomEncryption = true;
    }];

  nix.maxJobs = lib.mkDefault 5;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
    opengl = {
      driSupport32Bit = true;
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    trackpoint.enable = true;
    bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
      #powerOnBoot = false;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = "
        load-module module-switch-on-connect
      ";
    };
    openrazer.enable = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
