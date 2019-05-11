{ config, pkgs, nodejs, ... }:

with config.nixpkgs;
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

  dontRecurseIntoAttrs = x: x;
in rec {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # CLI *****************************
    qemu
    samba
    zfstools

    # devel
    awscli
    ansible
    ansible-lint
    awless
    rpm
    skopeo
    vagrant

    # network
    mobile-broadband-provider-info
    modemmanager
    networkmanager_strongswan
    strongswanNM
    usb_modeswitch
    linuxPackages.usbip

    # GUI *****************************
    # chat
    unstable.slack
    virtmanager

    # play
    steam
    unstable.wine
    unstable.winetricks

    # video
    ffmpeg-sixel

    # browsers
    google-chrome
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      steamPackages = dontRecurseIntoAttrs (pkgs.callPackage /mnt/nixos/steam { });
      steam = steamPackages.steam-chrootenv;
      steam-run = steam.run;
      steam-run-native = (steam.override {
        nativeOnly = true;
      }).run;

      steamcmd = steamPackages.steamcmd;
    };
  };
}

# ex: set et ts=2 sw=2 :
