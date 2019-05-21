# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      /mnt/nixos/common/user.nix
      ./zfs.nix
      ./bind-mounts.nix
      /mnt/nixos/common/pkgs.nix
      /mnt/nixos/common/network-manager.nix
      /mnt/nixos/common/external-devices.nix
      /mnt/nixos/common/shell.nix
      ./pkgs.nix
      /mnt/nixos/common/x.nix
      /mnt/nixos/common/kerberos.nix
      /mnt/nixos/common/steam.nix
      /mnt/nixos/common/synergy.nix
    ];

  nix = {
    gc = {
      automatic = true;
      dates = "19:15";
    };
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion       = "19.03";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-19.03";

  time.timeZone = "Europe/Prague";

  networking = {
    hostName = "mint540"; # Define your hostname.
    hostId   = "de93b847";

    networkmanager.enable = true;

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [
      22
      24800 # synergy server
    ];
    firewall.allowedUDPPorts = [
      24800 # synergy server
    ];
    firewall.allowPing = true;
  };

  programs = {
    adb.enable            = true;
    chromium.enable       = true;
    dconf.enable          = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };

  services = {
    hoogle.enable   = true;
    openssh = {
      enable     = true;
      forwardX11 = true;
    };
    printing = {
      enable = true;
      drivers = [pkgs.gutenprint pkgs.hplip pkgs.splix];
    };

    udev.extraRules =
      ''
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="54:ee:75:1f:1f:44", NAME="net0"
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="ce:0c:3c:82:b8:7e", NAME="wlan0"
        ACTION=="add", KERNEL=="i2c-[0-9]", GROUP="i2c"
      '';

    smartd = {
      enable = true;
      notifications = {
        x11.enable = true;
        test = true;
      };
    };

    xserver.videoDrivers = [ "intel" "nvidia" ];
  };

  virtualisation.docker.enable          = true;
  virtualisation.docker.enableOnBoot    = true;
  virtualisation.virtualbox.host.enable = true;

  systemd = {
    generator-packages = [ 
      pkgs.systemd-cryptsetup-generator
    ];
  };
}

# ex: set et ts=2 sw=2 :
