{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

  dontRecurseIntoAttrs = x: x;

in
{
  services = {
    udev = {
      packages = [ steamPackages.steam ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      steam
    ];
  };

  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      steamPackages = dontRecurseIntoAttrs (pkgs.callPackage /mnt/nixos/steam { });
      steam = steamPackages.steam-chrootenv;
      steam-run = steam.run;
      steam-run-native = (
        steam.override {
          nativeOnly = true;
        }
      ).run;

      steamcmd = steamPackages.steamcmd;
    };
  };
}

# ex: set et ts=2 sw=2 :
