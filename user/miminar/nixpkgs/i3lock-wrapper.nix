{ pkgs ? import <nixpkgs> {}, ... }:

with pkgs;
let
  wrapper = writeTextFile {
    name = "wrapper.sh";
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      IFS=$'\n\t'
      layout="$("${keyboard-layout}/bin/mysetxkbmap" -query | sed -n 's/^layout:\s*\(.*\)/\1/p')"
      function revert() {
        # restore dpms and keyboard layout to original state
        "${xorg.xset}/bin/xset" dpms 0 0 0
      }
      trap revert HUP INT TERM EXIT
      "${keyboard-layout}/bin/load-keyboard-layout.sh"
      "${xorg.xset}/bin/xset" +dpms dpms 5 5 5
      "${i3lock-color}/bin/i3lock-color" -n "$@"
      revert
    '';
  };
  resources = writeTextFile {
    name = "i3lock-xresources";
    text = ''
      Xautolock*time    : 10
      Xautolock*locker  : i3lock --keylayout 0 --clock
      Xautolock*killer  : lxqt-leave --logout
      Xautolock*notify  : 15
      Xautolock*notifier: notify-send -u low 'Screen lock' "I'm going to lock the screen in 15 seconds ..."
    '';
  };
  readme = writeTextFile {
    name = "readme.md";
    text = ''
      To finish installation
      
      1. Add the following line to your ~/.Xresources:

              #include "/home/miminar/.nix-profile/share/Xresources.d/i3lock"

      2. Reload the resources with `xrdb ~/.Xresources`.
      3. Restart the `xautolock` with `xautolock -restart`.
    '';
  };
in stdenv.mkDerivation {
  name = "i3lock-wrapper";
  version = i3lock-color.version;
  meta = i3lock-color.meta;

  buildInputs = [makeWrapper i3lock-color xorg.xset keyboard-layout];
  runtimeDependencies = [i3lock-color xorg.xset xautolock libnotify];
  phases = ["installPhase"];
  installPhase = ''
    makeWrapper "${wrapper}" "$out/bin/i3lock"
    mkdir -p $out/share/Xresources.d
    install -m 644 "${resources}" $out/share/Xresources.d/i3lock
    mkdir -p $out/share/i3lock
    install -m 644 "${readme}" $out/share/i3lock/README.md
  '';
}
