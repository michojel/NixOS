{ config, pkgs, nodejs, ... }:

with config.nixpkgs;
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in rec {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # CLI *****************************
    heimdal
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

    # GUI *****************************
    # chat
    unstable.slack
    virtmanager

    # play
    steam

    # browsers
    google-chrome
  ];
}

# ex: set et ts=2 sw=2 :
