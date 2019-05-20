# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./bind-mounts.nix
      /mnt/nixos/common/user.nix
      /mnt/nixos/common/pkgs.nix
      /mnt/nixos/common/network-manager.nix
      /mnt/nixos/common/external-devices.nix
      ./mpd-user.nix
      ./remote-mounts.nix
      /mnt/nixos/common/shell.nix
      /mnt/nixos/common/x.nix
    ];

  nix = {
    gc = {
      automatic = true;
      dates = "19:15";
    };
    maxJobs = 4;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion       = "19.03";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-19.03";

  time.timeZone = "Europe/Prague";

  networking = {
    hostName = "mx2"; # Define your hostname.

    networkmanager.enable = true;

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [
      22    # ssh
      5201  # iperf
      24800 # synergy server
    ];
    firewall.allowedUDPPorts = [
      5201  # iperf
      24800 # synergy server
    ];
    firewall.allowPing = true;
  };

  hardware = {
    pulseaudio.enable       = true;
    #pulseaudio.support32Bit = true;
    trackpoint.enable       = true;
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
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };

  services = {
    hoogle.enable   = true;
    openssh.enable  = true;
    printing = {
      enable = true;
      drivers = [pkgs.gutenprint pkgs.hplip pkgs.splix];
    };
    btrfs.autoScrub.enable = true;

    udev.extraRules =
      ''
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="68:f7:28:84:19:04", NAME="net0"
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="aa:03:dd:10:37:eb", NAME="wlan0"
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

  systemd = {
    generator-packages = [ 
      pkgs.systemd-cryptsetup-generator
    ];
  };
}
