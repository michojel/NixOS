# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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
      /mnt/nixos/common/docker.nix
      /mnt/nixos/common/x.nix
    ];

  profile.work = {
    enable = true;
    primary = false;
  };

  networking = {
    hostName = "mint540"; # Define your hostname.
    hostId = "578d6d20";

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

  virtualisation.docker = {
    storageDriver = "overlay2";
  };

  services = {
    fwupd.enable = true;
    smartd = {
      enable = true;
      notifications = {
        x11.enable = true;
        test = true;
      };
    };
    thinkfan = {
      enable = true;
      smartSupport = true;
    };
  };

  virtualisation = {
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  sound.enable = true;

  nixpkgs.config = {
    permittedInsecurePackages = [ ];

    packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
  };

  security.pki.certificates = import /mnt/nixos/secrets/certs/certs.nix;

}
