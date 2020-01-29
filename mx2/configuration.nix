# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      /mnt/nixos/common/essentials.nix
      ./bind-mounts.nix
      /mnt/nixos/common/user.nix
      /mnt/nixos/common/pkgs.nix
      /mnt/nixos/common/network-manager.nix
      /mnt/nixos/common/external-devices.nix
      ./mpd-user.nix
      /mnt/nixos/common/remote-mounts.nix
      /mnt/nixos/common/shell.nix
      /mnt/nixos/common/x.nix
      /mnt/nixos/common/printers.nix
      /mnt/nixos/common/synergy.nix
    ];

  networking = {
    hostName = "mx2"; # Define your hostname.

    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkAfter [
        22    # ssh
        # 5201  # iperf
      ];
      allowedUDPPorts = lib.mkAfter [
        # 5201  # iperf
      ];
      allowPing = true;
    };
    usePredictableInterfaceNames = false;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs = {
    adb.enable            = true;
    chromium.enable       = true;
    dconf.enable          = true;
  };

  nixpkgs = {
    config = {
      android_sdk.accept_license = true;
    };
  };

  services = {
    hoogle.enable   = true;
    printing = {
      enable = true;
      drivers = [pkgs.gutenprint pkgs.hplip pkgs.splix];
    };
    openssh = {
      enable  = true;
      extraConfig = ''
        X11Forwarding yes
      '';
    };
    btrfs.autoScrub.enable = true;

    udev.extraRules =
      ''
        ACTION=="add", KERNEL=="i2c-[0-9]", GROUP="i2c"
      '';

    smartd = {
      enable = true;
      notifications = {
        x11.enable = true;
        test = true;
      };
    };
  };

  virtualisation.docker.enable       = true;
  virtualisation.docker.enableOnBoot = true;
}
