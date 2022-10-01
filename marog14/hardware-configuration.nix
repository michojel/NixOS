# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

with config.nixpkgs;
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ./displaylink.nix
    ];

  #boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  #boot.kernelModules = [ "kvm-intel" "wacom" "v4l2loopback" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  #boot.kernelPackages = pkgs.linuxPackages_5_18;
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    device = "/dev/disk/by-uuid/D794-7C88";
    fsType = "vfat";
    options = [ "noatime" ];
  };

  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-uuid/19233405-6d01-41c4-b16f-51522c1feead";
    fsType = "ext4";
  };

  swapDevices =
    [{
      device = "/dev/disk/by-id/nvme-Corsair_MP600_PRO_XT_22167940000131035006-part2";
      randomEncryption = true;
    }];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      package = unstable.mesa.drivers;
      package32 = unstable.pkgsi686Linux.mesa.drivers;
      extraPackages = with pkgs; [
        amdvlk # vulkan
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
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
    pulseaudio.enable = false;
    openrazer.enable = true;
    video.hidpi.enable = lib.mkDefault true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    steam-hardware.enable = true;
  };
}
