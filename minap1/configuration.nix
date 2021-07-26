# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  hostName = "minap1";
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      /mnt/nixos/common/essentials.nix
      /mnt/nixos/common/user.nix
      ./bind-mounts.nix
      /mnt/nixos/common/remote-mounts.nix
      /mnt/nixos/secrets/redhat/mounts.nix
      /mnt/nixos/common/shell.nix
      /mnt/nixos/common/pkgs.nix
      /mnt/nixos/common/network-manager.nix
      /mnt/nixos/common/external-devices.nix
      ./pkgs.nix
      #./samba.nix
      /mnt/nixos/common/x.nix
      /mnt/nixos/common/monitoring.nix
      /mnt/nixos/common/docker.nix
      /mnt/nixos/secrets/redhat.nix
      /mnt/nixos/secrets/redhat/haproxy.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    zfs = {
      enableUnstable = true;
      requestEncryptionCredentials = true;
    };
    supportedFilesystems = [ "zfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModprobeConfig = ''
      # needed for thinkpad service
      options thinkpad_acpi experimental=1
    '';
  };

  services = {
    zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
  };

  environment.redhat = {
    enable = true;
    username = "miminar";
  };

  networking = {
    hostName = "minap1"; # Define your hostname.
    hostId = "98130871";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    #interfaces.wlan0.useDHCP = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # ssh
        #5201  # iperf
      ];
      allowedUDPPorts = [
        #5201  # iperf
        19000
      ];
      extraCommands = ''
        # samba
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i lo       --dport 139 -j ACCEPT
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i vboxnet0 --dport 139 -j ACCEPT
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i lo       --dport 445 -j ACCEPT
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i vboxnet0 --dport 445 -j ACCEPT
        # prometheus
        iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 9090 -s 192.168.178.57 -j ACCEPT
        iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 9100 -s 192.168.178.57 -j ACCEPT
      '';
      allowPing = true;
    };
    usePredictableInterfaceNames = false;
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
    nginx = {
      enable = true;
      #root = "/var/www";
      #listen = [ { addr = "127.0.0.1"; port = 80; } { addr = "192.168.122.1"; port = 80; } ];
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
      videoDrivers = [ "vesa" "modesetting" ];
    };
    thinkfan = {
      enable = true;
      smartSupport = true;
    };

  };

  security.pki.certificates = import /mnt/nixos/secrets/certs/certs.nix;

  virtualisation = {
    #podman = {
    #enable = true;
    #dockerCompat = true;
    #};
    docker.storageDriver = pkgs.lib.mkForce "zfs";
    docker.extraOptions = "--storage-opt zfs.fsname=zdata/local/docker";
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  sound.enable = true;

  nixpkgs.config = {
    permittedInsecurePackages = [
      "libsixel-1.8.6"
      "python2.7-Pillow-6.2.2"
    ];

    packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
  };
}
