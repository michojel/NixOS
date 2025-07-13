{ config, pkgs, lib, ... }:

let
  systemConfig = (import <nixpkgs/nixos> { system = config.nixpkgs.system; }).config;
in
{
  programs = {
    gpg = {
      enable = true;
    };
  };
  home.file.".gnupg/dirmngr.conf" = {
    text = ''
      keyserver hkps://keys.openpgp.org
      keyserver hpks://keys.gnupg.net
      keyserver hpks://pgp.mit.edu
      debug-all
      debug-level advanced
    '';
    onChange = "${pkgs.gnupg}/bin/gpgconf reload dirmngr";
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = !systemConfig.profile.server.enable;
    enableExtraSocket = !systemConfig.profile.server.enable;
    defaultCacheTtl = if systemConfig.profile.server.enable then 60 else 3600;
    maxCacheTtl = if systemConfig.profile.server.enable then 3600 else 3600 * 12;

    defaultCacheTtlSsh = if systemConfig.profile.server.enable then 0 else 3600;
    maxCacheTtlSsh = if systemConfig.profile.server.enable then 0 else 3600 * 12;
    pinentry = {
      package = if systemConfig.profile.server.enable then pkgs.pinentry-curses else pkgs.pinentry-gnome3;
    };
  };
}
