# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "enctank/mint540/root";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "enctank/mint540/home";
      fsType = "zfs";
    };

  fileSystems."/tmp" =
    { device = "enctank/mint540/tmp";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "enctank/mint540/nix";
      fsType = "zfs";
    };

  fileSystems."/mnt/nixos" =
    { device = "enctank/nixos";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-partuuid/287e82fa-5cea-443e-b4bb-000ccb6103de";
      fsType = "ext4";
      options = ["noatime"];
    };

  fileSystems."/boot/EFI" =
    { device = "/dev/disk/by-uuid/44F9-11FA";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/18759983-9a0b-4d65-b68a-bcb6aa90a3dc"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
    # Manage Optimus hybrid Nvidia video cards
    # TODO: make it work
    #bumblebee.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
    #steam-hardware.enable = true;
    pulseaudio.enable       = true;
    trackpoint.enable       = true;
  };
}
