# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sdhci_pci"
    "thinkpad_acpi"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "acpi_call" # recommended by tlp for battery re-calibration
    "kvm-intel"
    "wacom"
    "v4l2loopback"
    # "elevator=none"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  fileSystems."/" =
    {
      device = "rpool/system/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/2D42-69C8";
      fsType = "vfat";
      options = [ "noatime" "X-mount.mkdir" ];
    };

  fileSystems."/mnt/nixos" =
    {
      device = "rpool/system/nixos";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/home" =
    {
      device = "rpool/user/home";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/home/${config.local.username}" =
    {
      device = "rpool/user/home/${config.local.username}";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/root" =
    {
      device = "rpool/user/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/tmp" =
    {
      device = "rpool/local/tmp";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/nix" =
    {
      device = "rpool/local/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/var/lib/docker" =
    {
      device = "rpool/local/containers/docker";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };

  fileSystems."/home/miminar/Audio" =
    {
      device = "rpool/user/home/miminar/Audio";
      fsType = "zfs";
      options = [ "zfsutil" "x-gvfs-hide" ];
    };

  fileSystems."/home/miminar/Video" =
    {
      device = "rpool/user/home/miminar/Video";
      fsType = "zfs";
      options = [ "zfsutil" "x-gvfs-hide" ];
    };

  swapDevices = [{
    device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NZFN905864X-part2";
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
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    openrazer.enable = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
