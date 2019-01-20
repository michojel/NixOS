{ pkgs ? import <nixpkgs> {}, ... }:

with pkgs;

let
  layout  = "vok";
  variant = "";
  options = "grp:shift_caps_toggle,terminate:ctrl_alt_bksp";

in stdenv.mkDerivation {
  name = "keyboard-layout";
  srcs = [(pkgs.fetchFromGitLab {
    owner = "vojta_vogo";
    repo = "vok";
    rev = "9b338e5c8859830e09157e5e70498f65f980e3b2";
    sha256 = "1mz5dpizlkz858nv41dsi9idd7m9a4jgbwgld6lwklmaxg8qmadi";
  })];

  buildInputs = [makeWrapper xorg.xkbcomp xorg.setxkbmap];
  runtimeDependencies = [xorg.xkbcomp];
  phases = ["unpackPhase" "installPhase"];
  installPhase = let
    desktopItem = makeDesktopItem {
      name = "keyboard-layout-load";
      exec = "@out@/bin/load-keyboard-layout.sh";
      desktopName = "load-keyboard-layout";
    };
    layoutLoader = writeTextFile {
      name = "load-keyboard-layout.sh";
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail
        IFS=$'\n\t'

        "${pkgs.xorg.setxkbmap}/bin/setxkbmap" \
          -I @out@/share/X11/xkb \
          -layout "${layout}" -variant "${variant}" \
          -option "${options}" -print | \
            "${pkgs.xorg.xkbcomp}/bin/xkbcomp" -I@out@/share/X11/xkb - "''$DISPLAY"
      '';
    };
  in ''
    mkdir -p $out/share/X11/xkb/symbols
    install -m 0644 "xorg/vok" "$out/share/X11/xkb/symbols"
    mkdir -p $out/bin
    substituteAll "${layoutLoader}" "$out/bin/load-keyboard-layout.sh"
    chmod +x "$out/bin/load-keyboard-layout.sh"
    mkdir -p $out/share/applications
    substituteAll \
      "${desktopItem}/share/applications/"*.desktop \
      "$out/share/applications/load-keyboard-layout.desktop"
  '';
}
