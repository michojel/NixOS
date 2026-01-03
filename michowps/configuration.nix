{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./initrd-ssh.nix
  ];

  boot = {
    loader = {
      timeout = 15;
      grub = {
        configurationLimit = 5;
        enable = true;
        efiSupport = false;
        zfsSupport = true;
        device = "/dev/vda";
        copyKernels = true;
      };
    };
    zfs = {
      devNodes = "/dev/disk/by-partuuid/16331406-03";
      extraPools = [ "zroot" ];
    };
    tmp.cleanOnBoot = true;
    supportedFilesystems = [ "xfs" "zfs" ];
    kernelParams = [ "zswap.enabled=1" ];
    kernel.sysctl = {
      "net.ipv4.tcp_mtu_probing" = 1;
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "03:15";
      options = "--delete-older-than 17d";
    };
  };

  networking = {
    useDHCP = false;
    hostName = "michowps";
    domain = "michojel.cz";
    hostId = "fa2b0118";
    interfaces.ens3 = {
      useDHCP = false;
      mtu = 8900;
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
    defaultGateway6 = { address = "2a02:2b88:6::1"; interface = "ens3"; };
    firewall = {
      enable = true;
    };
  };

  time.timeZone = "Europe/Prague";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = false;
  };

  users.users.michojel = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ ];
  };

  environment = {
    systemPackages = with pkgs; [
      curl
      git
      htop
      iftop
      iotop
      jq
      mc
      moreutils
      neovim
      pciutils
      tmux
    ];
    variables = {
      EDITOR = lib.mkOverride 900 "nvim";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
    };
    fail2ban = {
      enable = true;
      ignoreIP = [
        "188.60.204.199"
      ];
      bantime-increment.enable = true;
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
