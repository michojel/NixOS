{ pkgs       ? import <nixpkgs> {}
, xkbLayout  ? "vok,ru"
, xkbVariant ? ","
, xkbOption  ? "grp:shift_caps_toggle,terminate:ctrl_alt_bksp"
, ...
}:

with pkgs;

let
  xkbLayout  = "vok,ru";
  xkbVariant = ",";
  xkbOption = "grp:shift_caps_toggle,terminate:ctrl_alt_bksp";

  desktopItem = makeDesktopItem {
    name = "keyboard-layout-load";
    exec = "@out@/bin/load-keyboard-layout.sh";
    desktopName = "load-keyboard-layout";
  };

  layoutLoader = writeTextFile {
    name = "load-keyboard-layout.sh";
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'

      "@out@/bin/mysetxkbmap" -option ""
      "@out@/bin/mysetxkbmap" \
        -layout "${xkbLayout}" -variant "${xkbVariant}" \
        -option "${xkbOption}" -print | \
          "@out@/bin/myxkbcomp" - "''$DISPLAY"
    '';
  };

  readme = writeTextFile {
    name = "README.md";
    text = ''
      To finish the installation, link the desktop file to ~/.config/autostart:

          ln -s ~/.nix-profile/share/applications/load-keyboard-layout.desktop \
            ~/.config/autostart
    '';
  };

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
  installPhase = ''
    mkdir -p $out/share/X11/xkb/symbols
    install -m 0644 "xorg/vok" "$out/share/X11/xkb/symbols"

    mkdir -p $out/bin
    substituteAll "${layoutLoader}" "$out/bin/load-keyboard-layout.sh"
    chmod +x "$out/bin/load-keyboard-layout.sh"
    makeWrapper "${pkgs.xorg.xkbcomp}/bin/xkbcomp" "$out/bin/myxkbcomp" \
      --add-flags -I$out/share/X11/xkb
    makeWrapper "${pkgs.xorg.setxkbmap}/bin/setxkbmap" "$out/bin/mysetxkbmap" \
      --add-flags -I --add-flags $out/share/X11/xkb

    mkdir -p $out/share/applications
    substituteAll \
      "${desktopItem}/share/applications/"*.desktop \
      "$out/share/applications/load-keyboard-layout.desktop"

    mkdir -p $out/share/keyboard-layout/doc/vok
    install -m 0644 LICENSE $out/share/keyboard-layout/doc/vok/LICENSE
    install -m 0644 "${readme}" $out/share/keyboard-layout/doc/
  '';
}
