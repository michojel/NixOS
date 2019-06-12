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
    generator-packages = [ 
      pkgs.systemd-cryptsetup-generator
    ];
    services.nixos-upgrade.preStart = ''
      ${pkgs.nix}/bin/nix-channel --update nixos-unstable
    '';
  };
}
