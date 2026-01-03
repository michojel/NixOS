{ config, pkgs, lib, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal-combined.nix> ];
  networking = {
    useDHCP = false;
    hostName = "michowps";
    domain = "michojel.cz";
    hostId = "fa2b0118";
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
    defaultGateway6 = { address = "2a02:2b88:6::1"; interface = "ens3"; };
    firewall = {
      allowedTCPPorts = [ 22 ];
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
  };

  environment = {
    systemPackages = with pkgs; [
      tmux
      jq
      mc
      git
      curl
      moreutils
      neovim
      htop
    ];
    variables = {
      EDITOR = lib.mkOverride 900 "nvim";
    };
  };
}

# ex: et ts=2 sw=2 :
