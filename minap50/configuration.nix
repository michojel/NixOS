# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

in {
  imports =
    [ ./hardware-configuration.nix
      /mnt/nixos/common/essentials.nix
      /mnt/nixos/common/user.nix
      ./zfs.nix
      ./bind-mounts.nix
      /mnt/nixos/common/shell.nix
      /mnt/nixos/common/pkgs.nix
      /mnt/nixos/common/network-manager.nix
      /mnt/nixos/common/external-devices.nix
      ./pkgs.nix
      ./samba.nix
      /mnt/nixos/common/x.nix
      /mnt/nixos/common/kerberos.nix
      /mnt/nixos/common/steam.nix
    ];

  networking = {
    hostName = "minap50"; # Define your hostname.
    hostId   = "f1e5c49e";

    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # ssh
        #5201  # iperf
        24800 # synergy server
      ];
      allowedUDPPorts = [
        #5201  # iperf
        24800 # synergy server
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
    interfaces = {
      net0 = {
        macAddress = "54:e1:ad:8f:73:1f";
        useDHCP = true;
        name = "net0";
      };
      wlp4s0 = {
        macAddress = "ac:ed:5c:64:9a:15";
        useDHCP = true;
        name = "wlan0";
      };
    };
    hosts = {
      "172.16.17.101" = ["w2k12vcenter.gscoe.intern" "w2k12vcenter"];
    };
  };

  programs = {
    adb.enable  = true;
    chromium    = {
      enable    = true;
      extraOpts = {
        "AuthServerWhitelist"            = "*.redhat.com";
        "AuthNegotiateDelegateWhitelist" = "*.redhat.com";
      };
    };
    dconf.enable          = true;
    ssh.startAgent        = false;
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
    nginx = {
      enable = true;
      #root = "/var/www";
      #listen = [ { addr = "127.0.0.1"; port = 80; } { addr = "192.168.122.1"; port = 80; } ];
    };

    udev = {
      extraRules = ''
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="54:e1:ad:8f:73:1f", NAME="net0"
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="d2:60:69:25:9b:47", NAME="wlan0"
        ACTION=="add",   KERNEL=="i2c-[0-9]", GROUP="i2c"
      '';
    };

    smartd          = {
      enable        = true;
      notifications = {
        x11.enable  = true;
        test        = true;
      };
    };

    synergy.client  = {
      enable        = true;
      screenName    = "minap50";
      serverAddress = "192.168.178.57";
    };

    xserver = {
      videoDrivers = [ "nvidia" ];
      deviceSection = ''
         Option     "RegistryDwords"  "RMUseSwI2c=0x01; RMI2cSpeed=100"
      '';
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

  virtualisation.docker.enable          = true;
  virtualisation.docker.enableOnBoot    = true;
  virtualisation.virtualbox.host.enable = true;
  systemd = {
    coredump.enable = true;
  };
}

# ex: et ts=2 sw=2 :
