# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  hostName = "mint15";
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./zfs.nix
      ./bind-mounts.nix
      /mnt/nixos/common/profile.nix
      /mnt/nixos/common/essentials.nix
      /mnt/nixos/common/remote-mounts.nix
      /mnt/nixos/common/shell.nix
      /mnt/nixos/common/pkgs.nix
      /mnt/nixos/common/network-manager.nix
      /mnt/nixos/common/external-devices.nix
      ./pkgs.nix
      /mnt/nixos/common/x.nix
      /mnt/nixos/common/monitoring.nix
      /mnt/nixos/common/pipewire.nix
    ];

  profile.work = {
    enable = true;
    primary = true;
  };

  networking = {
    hostName = "minap15"; # Define your hostname.
    hostId = "5d164cb2";

    useDHCP = false;
    interfaces.eth0.useDHCP = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
      ];
      allowPing = true;
    };
    usePredictableInterfaceNames = false;
  };

  programs = {
    adb.enable = true;
    chromium.enable = true;
  };

  nixpkgs = {
    config = {
      android_sdk.accept_license = true;
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  services = {
    fwupd.enable = true;
    openssh.enable = true;
    throttled.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplip pkgs.splix ];
    };

    smartd = {
      enable = true;
      notifications = {
        x11.enable = true;
        test = true;
      };
    };

    xserver = {
      videoDrivers = [ "vesa" "modesetting" ];
    };
  };

  virtualisation = {
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  nixpkgs.config = {
    permittedInsecurePackages = [ ];

    packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
  };
}