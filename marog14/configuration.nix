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
      # ./displaylink.nix
      /mnt/nixos/common/docker.nix
      /mnt/nixos/common/x.nix
      /mnt/nixos/common/obs.nix
    ];

  profile.work = {
    enable = true;
    primary = false;
  };

  i18n = {
    defaultLocale = "cs_CZ.UTF-8";
  };

  networking = {
    hostName = "marog14";
    hostId = "e2a11fa1";

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
    steam.enable = true;
    rog-control-center.enable = true;
  };

  # for steam
  # viz https://nixos.wiki/wiki/Steam#GE-Proton_.28GloriousEggroll.29
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    # Steam needs this to find Proton-GE
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    # note: this doesn't replace PATH, it just adds this to it
    PATH = [
      "\${XDG_BIN_HOME}"
    ];
  };

  qt.platformTheme = "gnome";

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
    asusd = {
      enable = true;
      asusdConfig = {
        text = ''
          {
            "bat_charge_limit": 80
          }
        '';
      };
    };
    supergfxd = {
      enable = true;
      settings = ''
        {
          "mode": "Hybrid",
          "vfio_enable": false,
          "vfio_save": false,
          "always_reboot": false,
          "no_logind": false,
          "logout_timeout_s": 180,
          "hotplug_type": "None"
        }
      '';
    };
    fwupd.enable = true;
    power-profiles-daemon = {
      enable = false; # conflicts with tlp
    };
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
    xserver = {
      videoDrivers = [
        # "displaylink"
        "amdgpu"
        "modesetting"
      ];
      displayManager.gdm.wayland = true;
    };
  };

  #  virtualisation = {
  #    virtualbox.host = {
  #      enable = true;
  #      enableExtensionPack = true;
  #    };
  #  };

  nixpkgs.config = {
    permittedInsecurePackages = [
      # TODO: remove
      "python-2.7.18.8"
      "vault-1.14.10"
      "electron-25.9.0"
      "qtwebengine-5.15.19"
    ];
  };
}
