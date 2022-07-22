{ config, lib, options, pkgs, nodejs, ... }:

with config.nixpkgs;
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in
rec {

  # Copied from: https://nixos.wiki/wiki/Overlays
  # With existing `nix.nixPath` entry:
  nix.nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/mnt/nixos/overlays-compat" ];
  nixpkgs = {
    config = {
      # obsoleted by overlays
      packageOverrides = pkgs: rec { };

      # directory with individual overlays in files
      overlays = "/mnt/nixos/overlays-compat";
    };
    overlays = with lib; let
      # inspired by: https://github.com/Infinisil/system/blob/382406251e10412baa6b0fda40bbe22aafd4a86d/config/new-modules/default.nix
      # Recursively constructs an attrset of a given folder, recursing on directories, value of attrs is the filetype
      getDir = dir: mapAttrs
        (
          file: type:
            if type == "directory" then getDir "${dir}/${file}" else type
        )
        (builtins.readDir dir);

      # Collects all files of a directory as a list of strings of paths
      files = dir: collect isString (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

      # Filters out directories that don't end with .nix or are this file, also makes the strings absolute
      validFiles = dir: map (file: dir + "/${file}") (filter (file: hasSuffix ".nix" file && file != "default.nix") (files dir));
    in
    map (import) (validFiles /mnt/nixos/overlays);
  };


  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    duplicity
    duply
    nixpkgs-fmt
    nix-linter
    nix-review
    openssl
    php
    sqlite
  ];
}
