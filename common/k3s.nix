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
  environment.systemPackages = [ k3s ];
  services = {
    k3s = {
      enable = true;
      role = "server";
      package = k3s;
    };
  };
  networking = {
    firewall = {
      allowedTCPPorts = [
        22 # ssh
        # TODO: do not expose those ports to public
        6443
        10250
        443
      ];
    };
  };
}
