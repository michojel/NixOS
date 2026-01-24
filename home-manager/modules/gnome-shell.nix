{ config, pkgs, lib, ... }:

let
  # TODO: share this somehome between modules
  systemConfig = (import <nixpkgs/nixos> { system = config.nixpkgs.system; }).config;
in
{
  programs.gnome-shell = lib.mkIf (!systemConfig.profile.server.enable) {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.appindicator; }
      { package = pkgs.gnomeExtensions.kimpanel; }
      { package = pkgs.gnomeExtensions.paperwm; }
      { package = pkgs.gnomeExtensions.wsp-windows-search-provider; }
      { package = pkgs.gnomeExtensions.just-perfection; }
      { package = pkgs.gnomeExtensions.vitals; }
    ];
  };
}
