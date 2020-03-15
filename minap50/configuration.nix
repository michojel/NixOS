# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  #  unstable = import <nixos-unstable> {
  #    config = {
  #      allowUnfree = true;
  #    };
  #  };
  hostName = "minap50";

in
{
  imports =
    [
      ./hardware-configuration.nix
      /mnt/nixos/common/essentials.nix
      /mnt/nixos/common/user.nix
      ./zfs.nix
      ./bind-mounts.nix
      /mnt/nixos/common/remote-mounts.nix
      /mnt/nixos/secrets/rht/mounts.nix
      /mnt/nixos/common/shell.nix
      /mnt/nixos/common/pkgs.nix
      /mnt/nixos/common/network-manager.nix
      /mnt/nixos/common/external-devices.nix
      ./pkgs.nix
      ./samba.nix
      /mnt/nixos/common/x.nix
      /mnt/nixos/common/docker.nix
      /mnt/nixos/common/kerberos.nix
      #/mnt/nixos/common/steam.nix
      /mnt/nixos/common/printers.nix
    ];

  networking = {
    hostName = "${hostName}"; # Define your hostname.
    hostId = "f1e5c49e";

    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
        #5201  # iperf
      ];
      allowedUDPPorts = [
        #5201  # iperf
      ];
      extraCommands = ''
        # samba
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i lo       --dport 139 -j ACCEPT
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i vboxnet0 --dport 139 -j ACCEPT
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i lo       --dport 445 -j ACCEPT
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i vboxnet0 --dport 445 -j ACCEPT
      '';
      allowPing = true;
    };
    useDHCP = lib.mkForce true;
    hosts = {
      "172.16.17.101" = [ "w2k12vcenter.gscoe.intern" "w2k12vcenter" ];
    };
    usePredictableInterfaceNames = false;
  };

  nix.useSandbox = true;

  programs = {
    adb.enable = true;
    chromium = {
      enable = true;
      extraOpts = {
        "AuthServerWhitelist" = "*.redhat.com";
        "AuthNegotiateDelegateWhitelist" = "*.redhat.com";
      };
    };
    dconf.enable = true;
  };

  nixpkgs = {
    config = {
      android_sdk.accept_license = true;
    };
  };

  # for NVIDIA drivers
  # - issues
  #   - https://github.com/NixOS/nixpkgs/issues/48424
  #   - https://github.com/NixOS/nixpkgs/issues/32580
  environment.variables.WEBKIT_DISABLE_COMPOSITING_MODE = "1";

  services = {
    hoogle.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplip pkgs.splix ];
    };
    nginx = {
      enable = true;
      #root = "/var/www";
      #listen = [ { addr = "127.0.0.1"; port = 80; } { addr = "192.168.122.1"; port = 80; } ];
    };

    udev = {
      extraRules = ''
        ACTION=="add",   KERNEL=="i2c-[0-9]", GROUP="i2c"
        # QuataFire 610
        ACTION=="add", SUBSYSTEM=="firewire", ATTR{units}=="0x00a02d:0x010001", GROUP="audio"
      '';
    };

    smartd = {
      enable = true;
      notifications = {
        x11.enable = true;
        test = true;
      };
    };

    synergy.client = {
      enable = true;
      screenName = hostName;
      serverAddress = "192.168.178.57";
    };

    xserver = {
      videoDrivers = [ "nvidia" ];
      deviceSection = ''
        Option     "RegistryDwords"  "RMUseSwI2c=0x01; RMI2cSpeed=100"
      '';
      dpi = 96;
    };

    jack = {
      jackd = {
        enable = true;
        extraOptions = [ "-dfirewire" "-n" "3" "-p" "2048" "-v4" ];
      };
    };
  };


  # TODO: automate the certs.nix file creation
  security.pki.certificates = import /mnt/nixos/secrets/certs/certs.nix;
  #    [
  #    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  #    certs/SAP-Global-Root-CA.crt
  #    certs/2015-RH-IT-Root-CA.pem
  #    certs/Eng-CA.crt
  #    certs/newca.crt
  #    certs/oracle_ebs.crt
  #    certs/pki-ca-chain.crt
  #];

  #virtualisation.docker.enable          = true;
  #virtualisation.docker.enableOnBoot    = true;
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
  systemd = {
    # has no longer any effect
    #coredump.enable = true;
    user.services.synergy-mx2-client = {
      after = [ "network.target" "graphical-session.target" ];
      conflicts = [ "synergy-client" ];
      description = "Synergy client to mx2";
      #wantedBy = optional cfgC.autoStart "graphical-session.target";
      path = [ pkgs.synergy ];
      serviceConfig.ExecStart = ''${pkgs.synergy}/bin/synergyc -f -n minap50 mx2.mihoje.me'';
      serviceConfig.Restart = "on-failure";
    };
  };
}

# ex: et ts=2 sw=2 :
