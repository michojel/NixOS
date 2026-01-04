{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./initrd-ssh.nix
    /etc/nixos.d/common/profile.nix
    /etc/nixos.d/common/docker.nix
    ./anki-syncserver.nix
    ./authentik.nix
  ];

  profile = {
    private.enable = true;
    server.enable = true;
  };

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
    firewall =
      let
        allowedTCPPorts = [ 22 80 443 ];
        allowedIPv4Ranges = {
          "83.79.0.0/16" = "Swisscom-TI";
          "51.154.0.0/16" = "Salt-Mobile-SA";
          "213.55.128.0/17" = "Salt-Mobile-SA";
          "194.230.0.0/16" = "Sunrise-CH";
          "129.132.0.0/16" = "ETH_Zürich";
          "82.130.64.0/18" = "ETH_Zürich";
          "192.33.96.0/21" = "ETH_Zürich";
          "192.33.92.0/22" = "ETH_Zürich";
          "192.33.108.0/23" = "ETH_Zürich";
        };

        allowedIPv6Ranges = {
          "2a04:ee40::/29" = "Salt-Mobile-SA";
          "2001:1700::/27" = "Sunrise-CH";
          "2a02:aa00::/27" = "Sunrise-CH";
          "2001:1700::/28" = "Sunrise-CH";
          "2a02:aa00::/28" = "Sunrise-CH";
          "2a02:aa10::/28" = "Sunrise-CH";
          "2a00:e2c0::/32" = "Sunrise-CH";
          "2a01:b460::/32" = "Sunrise-CH";
          "2a0f:f0c0::/32" = "Sunrise-CH";
          "2a00:e2c0::/33" = "Sunrise-CH";
          "2a00:e2c0:8000::/33" = "Sunrise-CH";
          "2001:67c:10ec::/48" = "ETH_Zürich";
        };

        iptRule = version: range: comment: (lib.concatStringsSep " " [
          (if version == 6 then "ip6tables" else "iptables")
          "-A allowed_ip_ranges --match multiport -m comment"
          "-s ${range}"
          "-m state --state NEW -m tcp -p tcp"
          "--dports ${lib.concatStringsSep "," (map (p: toString p) allowedTCPPorts)}"
          "-j ACCEPT"
          "--comment ${comment}"
        ]);
      in
      {
        # allowedTCPPorts = [ 22 80 443 ];
        ## for ACME, TODO: switch to DNS-01 Challenge
        allowedTCPPorts = [ 80 ];
        enable = true;
        # TODO: switch to nftables
        extraCommands = lib.concatStringsSep "\n" (
          lib.concatLists [
            [
              ''
                iptables -N allowed_ip_ranges
                iptables -A INPUT -j allowed_ip_ranges
              ''
            ]
            (lib.attrsets.mapAttrsToList (iptRule 4) allowedIPv4Ranges)
            [ "iptables -A allowed_ip_ranges -s 0.0.0.0/0 -j RETURN" ]
            [
              ''
                ip6tables -N allowed_ip_ranges
                ip6tables -A INPUT -j allowed_ip_ranges
              ''
            ]
            (lib.attrsets.mapAttrsToList (iptRule 6) allowedIPv6Ranges)
            [ "ip6tables -A allowed_ip_ranges -s 0.0.0.0/0 -j RETURN" ]
          ]);
        extraStopCommands = ''
          ip6tables -D INPUT -j allowed_ip_ranges ||:
          ip6tables -F allowed_ip_ranges ||:
          ip6tables -X allowed_ip_ranges ||:

          iptables -D INPUT -j allowed_ip_ranges ||:
          iptables -F allowed_ip_ranges ||:
          iptables -X allowed_ip_ranges ||:
        '';
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

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    bash.interactiveShellInit = ''
      HISTCONTROL=erasedups:ignorespace
      HISTFILESIZE=100000
      HISTSIZE=10000

      shopt -s histappend
      shopt -s checkwinsize
      shopt -s extglob
      shopt -s globstar
      shopt -s checkjobs
    '';
    fzf = {
      keybindings = true;
      fuzzyCompletion = true;
    };
    direnv = {
      enable = true;
    };
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

    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
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
