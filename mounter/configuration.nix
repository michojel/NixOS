# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  hostname = "nixosmounter";
  fqdn = hostname + ".vm";
  ipv4addr = "192.168.56.10";
in {
  imports = [
      ./hardware-configuration.nix
      ./bind-mounts.nix
      /mnt/nixos/common/shell.nix
      /mnt/nixos/common/docker.nix
      /mnt/nixos/common/certs.nix
      ./samba.nix
    ];

  nix = {
    gc = {
      automatic = true;
      dates = "19:15";
    };
    nixPath = [
      "nixpkgs=/mnt/nixos/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
      "/etc"
    ];
  };

  boot = {
    loader = {
      grub = {
        enable     = true;
        version    = 2;
        device     = "/dev/sda";
        efiSupport = false;
      };

      timeout = 1;
    };

    initrd = {
      availableKernelModules = [ "virtio_net" "virtio_pci" ];
      network = {
        enable = true;

        ssh = {
          enable         = true;
          port           = 2222;
          hostECDSAKey   = /run/keys/initrd-ssh-key;
          authorizedKeys = [
            "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBlBzV4RWd3RvQFodPo4f9hx9FExQ/qgoXP23v423Dg8HtTzH/GxEW1VwjTaPxX5Ccsc7raWZLVbe3BXkW2ne50= root@nixosmounter"
          ];
        };

        postCommands = ''
          echo "zfs load-key -a; killall zfs" >> /root/.profile
        '';
      };

      checkJournalingFS = false;
    };

    kernelParams = [
      # in initrd the enp0s8 is named eth1
      "ip=${ipv4addr}:::255.255.255.0:nixosmounter:eth1:off"
    ];

    supportedFilesystems = ["zfs"];
    #zfs.enableUnstable   = true;
  };

  # move if lvm is used
  systemd.services = {
    systemd-udev-settle.serviceConfig.ExecStart = "${pkgs.coreutils}/bin/true";
    tor = {
      # do not start at boot
      wantedBy   = lib.mkForce [];
    };
    polipo = {
      # do not start at boot
      wantedBy   = lib.mkForce [];
      requires   = lib.mkAfter ["tor.service"];
      after      = lib.mkAfter ["tor.service"];
    };
  };

  networking = {
    hostName = fqdn;
    hostId   = "1c64fb8b";

    hosts = {
      "${ipv4addr}"   = [ hostname fqdn ];
      "192.168.56.51" = [ "ocentop" "ocentop.vm" "ocentop.minap50" ];
      "192.168.56.1"  = [ "minap50win" "win.minap50" ];
    };

    interfaces  = {
      "enp0s3"  = {
        useDHCP = true;
      };
      #"enp0s8"         = {
      "eth1"           = {
        useDHCP        = false;
        ipv4.addresses = [ { address = ipv4addr ; prefixLength = 24; } ];
      };
    };

    firewall = {
      enable          = true;
      allowPing       = true;
      allowedTCPPorts = [
		    22 139 445    # samba
        8123          # tor http proxy
			];
    };

    networkmanager = {
      enable    = true;
      logLevel  = "INFO";
      unmanaged = ["enp0s8" "eth1"];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    bindfs
    cifs-utils
    drive
    ghostscript
    imagemagick
    nodePackages.eslint
    linuxPackages.virtualboxGuestAdditions
    nodejs
    pdftk
    samba

    # available with my patches in misable branch
    nodePackages.eslint-config-google
    megafuse
    nodePackages."@google/clasp"

    # not compilable on 18.09
    #ocamlPackages.unison
    vorbisTools

    # graphical
    anki
    xfce.ristretto
    virtviewer
    xorg.xkbcomp

    # work related
    #aws
    awscli
    aws_shell
    skopeo
    graphviz

    # nixos
    nix-prefetch-git

    # devel
    pandoc
    python36Packages.autopep8
    python36Packages.flake8
    python36Packages.pylint
    python36Packages.yapf
    python36Packages.virtualenv
    gcc
    glide
    gnumake
    quilt
    go
  ];

  services.xserver = {
    enable = true;
    exportConfiguration = true;

    layout = "us,cz,ru";
    xkbVariant = ",qwerty,";
    xkbOptions = "grp:shift_caps_toggle,terminate:ctrl_alt_bksp,grp:switch,grp_led:scroll";

    libinput = {
      enable = true;
      clickMethod = "none";
      tapping = false;
    };
  };

  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot.enable = true;
  };

  services.openssh = {
    enable = true;
    forwardX11 = true;
    permitRootLogin = "yes";
  };

  services.tor = {
    enable = true;
    torsocks.enable = true;
    torsocks.allowInbound = true;
    #torsocks.server = "192.168.56.10:9050";
  };

  services.polipo = {
    enable = true;
    allowedClients = ["127.0.0.1" "::1" "192.168.56.0/24"];
    # map to top SOCKS proxy
    socksParentProxy = "localhost:9050";
    proxyAddress = "0.0.0.0";
    extraConfig =
      ''
        diskCacheRoot = ""
      '';
  };

  nixpkgs.config.permittedInsecurePackages = [
    "polipo-1.1.1"
  ];


  system.stateVersion = "18.09";

  users.extraUsers.miminar = {
    isNormalUser = true;
    uid          = 1000;
    extraGroups  = [
      "docker"
      "fuse"
      "networkmanager"
      # to open tmux
      "utmp"
      "wheel"
    ];
  };

	# needed for jackd
  #security.rtkit.enable = true;
}

# vim: set ts=2 sw=2 :
