{ config, pkgs, ... }:

with pkgs;
with lib;

let
  xComposeFile = writeTextFile {
    name = "XCompose";
    text = replaceStrings [ "\"%L\"" ] [ "\"${xlibs.libX11}/share/X11/locale/cs_CZ.UTF-8/Compose\"" ]
      (builtins.readFile ./XCompose);
  };

in
rec {
  system.userActivationScripts = {
    xcompose = ''
      ln -sf "${xComposeFile}" ~/.XCompose
    '';
  };
}
