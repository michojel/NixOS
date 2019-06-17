{ config, pkgs, nodejs, ... }:

rec {
  nix = {
    gc = {
      automatic = true;
      dates = "19:15";
      # Options given to nix-collect-garbage when the garbage collector is run automatically. 
      options = "--delete-older-than 21d";
    };
  };

  boot.loader.timeout = 2;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion        = "19.03";
  system.autoUpgrade.enable  = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-19.03";

  time.timeZone = "Europe/Prague";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  services = {
    openssh = {
      enable     = true;
      forwardX11 = true;
    };
  };

  systemd = {
    generator-packages = pkgs.lib.mkAfter [ 
      pkgs.systemd-cryptsetup-generator
    ];
    services.nixos-upgrade = {
      preStart = ''
        set -euo pipefail
        ${pkgs.sudo}/bin/sudo -u miminar "${pkgs.bash}/bin/bash" \
          -c 'cd /home/miminar/wsp/nixos && git pull https://github.com/michojel/NixOS master'
        ${pkgs.nix}/bin/nix-channel --update nixos-unstable
      '';
      requires = pkgs.lib.mkAfter [ "network-online.target" ];
      after = pkgs.lib.mkAfter [ "network-online.target" ];
    };
  };
}
