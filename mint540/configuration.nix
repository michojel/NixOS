# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      /mnt/nixos/common/essentials.nix
      /mnt/nixos/common/user.nix
      ./zfs.nix
      ./bind-mounts.nix
      /mnt/nixos/common/remote-mounts.nix
      /mnt/nixos/common/pkgs.nix
      /mnt/nixos/common/network-manager.nix
      /mnt/nixos/common/external-devices.nix
      /mnt/nixos/common/shell.nix
      ./pkgs.nix
      /mnt/nixos/common/x.nix
      /mnt/nixos/common/docker.nix
      /mnt/nixos/common/kerberos.nix
      #/mnt/nixos/common/steam.nix
      /mnt/nixos/common/synergy.nix
      /mnt/nixos/common/ping-hosts-timer.nix
      /mnt/nixos/common/printers.nix
      /mnt/nixos/common/firewire-audio.nix
    ];


  networking = {
    hostName = "mint540"; # Define your hostname.
    hostId = "de93b847";
    usePredictableInterfaceNames = false;

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [
      22
    ];
    firewall.allowedUDPPorts = [];
    firewall.allowPing = true;
  };

  programs = {
    adb.enable = true;
    chromium.enable = true;
    dconf.enable = true;
  };

  nixpkgs = {
    config = {
      android_sdk.accept_license = true;
    };
  };

  services = {
    hoogle.enable = true;

    smartd = {
      enable = true;
      notifications = {
        x11.enable = true;
        test = true;
      };

    };
    firewire = {
      enable = true;
      net.server.enable = true;
    };

    #xserver.videoDrivers = [ "nvidia" "intel" ];
    xserver.videoDrivers = [ "vesa" "intel" ];
    synergy.server = {
      autoStart = true;
    };
  };

  security.pki.certificates = import /mnt/nixos/secrets/certs/certs.nix;

  #hardware.nvidia.optimus_prime.enable = true;
  #hardware.nvidia.optimus_prime.intelBusId = "PCI:0:2.0";
  #hardware.nvidia.optimus_prime.nvidiaBusId = "PCI:1:0.0";
  #hardware.nvidia.modesetting.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
  nix.useSandbox = true;
}

# ex: set et ts=2 sw=2 :
