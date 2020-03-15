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
    libxfs
    ffado

    # work
    unstable.awscli
    skopeo
    unstable.slack

    # virtualization
    libvirt
    virtmanager

    wine
  ];
}

# ex: set et ts=2 sw=2 :
