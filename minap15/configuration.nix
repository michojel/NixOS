# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
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
      /mnt/nixos/common/docker.nix
      /mnt/nixos/common/caching-proxy.nix
      # /mnt/nixos/common/virtualbox.nix
      /mnt/nixos/common/obs.nix
      # /mnt/nixos/common/k3s.nix
    ];

  profile.work = {
    enable = true;
    primary = true;
  };

  networking = {
    hostName = "minap15"; # Define your hostname.
    hostId = "5d164cb2";

    useDHCP = false;

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

  # environment.systemPackages = [ unstable.k3s ];
  services = {
    fwupd.enable = true;
    openssh.enable = true;
    throttled.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplip pkgs.splix pkgs.epson-escpr pkgs.epson-escpr2 ];
    };

    smartd = {
      enable = true;
      notifications = {
        x11.enable = true;
        test = true;
      };
    };

    tlp = {
      enable = true;
      settings = {
        # viz https://linrunner.de/tlp/faq/battery.html#battery-care
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 85;

        # viz https://linrunner.de/tlp/support/optimizing.html#reduce-power-consumption-fan-noise-on-ac-power
        RUNTIME_PM_ON_AC = "auto";
        RUNTIME_PM_ON_BAT = "auto";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        WIFI_PWR_ON_AC = "on";
        WIFI_PWR_ON_BAT = "on";
      };
    };
    power-profiles-daemon = {
      enable = false;
    };

    xserver = {
      videoDrivers = [ "vesa" "modesetting" ];
    };
    thinkfan = {
      enable = false;
      smartSupport = false;
    };
  };

  systemd.services.thinkfan.preStart = (lib.concatStringsSep " " [
    "/run/current-system/sw/bin/modprobe -r thinkpad_acpi &&"
    "/run/current-system/sw/bin/modprobe thinkpad_acpi"
  ]);


  qt = {
    platformTheme = "gnome";
    style = "adwaita";
  };

  nixpkgs.config = {
    packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
  };


  virtualisation.containers = {
    enable = true;
  };
}
