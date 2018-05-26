# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  hostname = "nixosmounter";
  fqdn = hostname + ".vm";
  ipv4addr = "192.168.56.10";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot = {
    # Use the GRUB 2 boot loader.
    loader = {
      grub.enable = true;
      grub.version = 2;
      grub.efiSupport = false;
      # Define on which hard drive you want to install Grub.
      grub.device = "/dev/sda"; # or "nodev" for efi only
      timeout = 1;
    };

    supportedFilesystems = [ "zfs" ];
    zfs.enableUnstable = true;

    initrd = {
      availableKernelModules = [ "virtio_net" "virtio_pci" ];
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostECDSAKey = /run/keys/initrd-ssh-key;
          authorizedKeys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBlBzV4RWd3RvQFodPo4f9hx9FExQ/qgoXP23v423Dg8HtTzH/GxEW1VwjTaPxX5Ccsc7raWZLVbe3BXkW2ne50= root@nixosmounter" ];
        };
        postCommands = ''
          echo "zfs load-key -a; killall zfs" >> /root/.profile
        '';
      };
    };
    kernelParams = [
      # in initrd the enp0s8 is named eth1
      "ip=${ipv4addr}:::255.255.255.0:nixosmounter:eth1:off"
    ];
  };

  networking = {
    hostName = "nixosmounter";
    wireless.enable = false;
    hostId = "1c64fb8b";
    interfaces = {
      "enp0s3"  = {
        useDHCP = true;
      };
      #"enp0s8"         = {
      "eth1"         = {
        useDHCP        = false;
        ipv4.addresses = [ { address = ipv4addr ; prefixLength = 24; } ];
      };
    };
    networkmanager = {
      enable = true;
      #unmanaged = ["enp0s8"];
      unmanaged = ["eth1"];
    };
  };


  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  environment = {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      ag
      anki
      bc
      bind
      cryptsetup
      curl
      duplicity
      fzf
      git
      gitAndTools.git-annex
      gnupg
      gnupg1compat
      gptfdisk
      htop
      mc
      megatools
      neovim
      ntp
      ocamlPackages.unison
      pciutils
      pinentry
      procps
      tmux
      tmuxinator
      vim
      wget
      xfce.ristretto
      zfstools
    ];
    shells = [pkgs.bashInteractive];
    variables = { EDITOR = lib.mkOverride 900 "nvim"; };
  };

  programs = {
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    bash.enableCompletion = true;
    command-not-found.enable = true;
    gnupg.agent = { enable = true; enableSSHSupport = true; };
    #vim.defaultEditor     = true;

    tmux = {
      enable              = true;
      clock24             = true;
      historyLimit        = 10000;
      keyMode             = "vi";
      newSession          = true;
      terminal            = "screen-256color";
    };
  };


  # List services that you want to enable:
  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    forwardX11 = true;
    permitRootLogin = "yes";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.miminar = {
     isNormalUser = true;
     uid = 1000;
     extraGroups = [ "networkmanager" "wheel" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.nixos.stateVersion = "18.03"; # Did you read the comment?

  nix.gc = {
    automatic = true;
    dates = "19:40";
  };


  security = {
    sudo.extraConfig = ''
        Defaults:root,%wheel  !tty_tickets
        Defaults:root,%wheel  timestamp_timeout = 10
        Defaults:root,%wheel  env_keep+=EDITOR
      '';
   };


}
