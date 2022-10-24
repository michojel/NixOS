# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./zfs.nix
      ./bind-mounts.nix
      /mnt/nixos/common/pipewire.nix
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
      /mnt/nixos/common/obs.nix
      ./asusd.nix
    ];

  profile.work = {
    enable = true;
    primary = false;
  };

  networking = {
    hostName = "marog14";
    hostId = "e2a11fa1";

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
        24800 # barrier
      ];
      allowPing = true;
    };
    usePredictableInterfaceNames = false;
  };

  programs = {
    adb.enable = true;
    chromium.enable = true;
    steam.enable = true;
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
    asusd.enable = true;
    fwupd.enable = true;
    smartd = {
      enable = true;
      notifications = {
        x11.enable = true;
        test = true;
      };
    };
    xserver = {
      videoDrivers = [
        "displaylink"
        "modesetting"
        "amdgpu"
      ];
    };
  };

  users.extraUsers.sona = {
    uid = 1001;
    description = "Soňa";
    isNormalUser = true;
  };

  virtualisation = {
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };
}
