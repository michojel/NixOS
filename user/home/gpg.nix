{ config, pkgs, lib, ... }:

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
}
