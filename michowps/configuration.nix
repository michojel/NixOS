# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #/mnt/nixos/common/essentials.nix
      /mnt/nixos/common/profile.nix
      /mnt/nixos/common/shell.nix
      /mnt/nixos/common/docker.nix
      #/mnt/nixos/common/pkgs.nix
      ./bind-mounts.nix
      #./adminer.nix
      ./pkgs.nix
      ./wp-sites.nix
      ./gitlab.nix
      ./anki-syncserver.nix
      ./grist-server.nix
      # ./postgresql-25.05-up.nix
    ];

  profile = {
    private.enable = true;
    server.enable = true;
  };

  # Use the GRUB 2 boot loader.
  boot = {
    loader = {
      grub.enable = true;
      grub.efiSupport = false;
      #  grub.efiInstallAsRemovable = true;
      #  efi.efiSysMountPoint = "/boot/efi";
      # Define on which hard drive you want to install Grub.
      grub.device = "/dev/vda"; # or "nodev" for efi only
      grub.copyKernels = true;
    };
    supportedFilesystems = [ "btrfs" "xfs" ];
    tmp.cleanOnBoot = true;
    loader.timeout = 31;
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "03:15";
      # Options given to nix-collect-garbage when the garbage collector is run automatically.
      options = "--delete-older-than 21d";
    };
  };

  systemd = {
    tmpfiles.rules = [ "d /tmp 1777 root root 11d" ];
    services.nixos-upgrade = {
      preStart = ''
        set -euo pipefail
        ${pkgs.sudo}/bin/sudo -u ${config.local.username} "${pkgs.bash}/bin/bash" \
          -c 'cd /home/miminar/wsp/nixos && git pull https://github.com/michojel/NixOS master'
        ${pkgs.nix}/bin/nix-channel --update nixos-unstable
      '';
      postStart = ''
        ${pkgs.sudo}/bin/sudo -u ${config.local.username} "${pkgs.bash}/bin/bash" \
          -c 'cd $HOME && nix-env --upgrade "*"
            nix-env -iA nixos.chrome-wrappers nixos.w3'
        # remove when https://github.com/NixOS/nixpkgs/pull/86489 is available
      '';
      requires = pkgs.lib.mkAfter [ "network-online.target" ];
      after = pkgs.lib.mkAfter [ "network-online.target" ];
    };
  };

  virtualisation.docker.storageDriver = "overlay2";


  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    useDHCP = false;
    hostName = "michowps";
    hostId = "f08e11d9";
    domain = "michojel.cz";
    interfaces.ens3 = {
      useDHCP = false;
      ipv4 = {
        addresses = [{ address = "31.31.73.95"; prefixLength = 24; }];
      };
      ipv6 = {
        addresses = [
          { address = "2a02:2b88:2:1::6c17:1"; prefixLength = 64; }
          { address = "2a02:2b88:6:6c17::1"; prefixLength = 48; }
        ];
      };
    };
    nameservers = [
      "46.28.108.2"
      "31.31.72.3"
      "2a02:2b88:2:1::2552:1"
      "2a02:2b88:2:1::af4:1"
    ];
    defaultGateway = { address = "31.31.73.1"; interface = "ens3"; };
    #defaultGateway6 = { address = "2a02:2b88:2:1::1"; interface = "ens3"; };
    defaultGateway6 = { address = "2a02:2b88:6::1"; interface = "ens3"; };

    # Open ports in the firewall.
    firewall = {
      allowedTCPPorts = [ 22 80 443 ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      enable = true;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the OpenSSH daemon.
  services = {
    openssh.enable = true;
    btrfs.autoScrub.enable = true;
    irqbalance.enable = true;
    fail2ban = {
      enable = true;
      ignoreIP = [
        "188.60.204.199"
      ];
      bantime-increment.enable = true;
    };

    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    postgresql = {
      # required for gitlab 18
      package = pkgs.postgresql_16;
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  security = {
    acme = {
      acceptTerms = true;
      defaults = {
        email = "mm@michojel.cz";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
