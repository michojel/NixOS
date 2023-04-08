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
    enableSshSupport = true;
    defaultCacheTtl = 3600;
    maxCacheTtl = 3600 * 12;

    defaultCacheTtlSsh = 3600;
    maxCacheTtlSsh = 3600 * 12;
    pinentryFlavor =
      if systemConfig.profile.server.enable then
        "curses"
      else
        "gnome3";
  };
}
