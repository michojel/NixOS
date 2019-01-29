{ pkgs ? import <nixpkgs> {}, ... }:

with pkgs;
let
  foregroundWrapper = writeTextFile {
    name = "foreground-wrapper.sh";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      IFS=$'\n\t'
      function revert() {
        # restore dpms to original state
        "${xorg.xset}/bin/xset" dpms 0 0 0
      }
      trap revert HUP INT TERM EXIT
      "${keyboard-layout}/bin/load-keyboard-layout.sh"
      "${xorg.xset}/bin/xset" +dpms dpms 5 5 5
      "@out@/bin/i3lock-fancy" "$@"
    '';
  };
  wrapper = writeTextFile {
    name = "wrapper.sh";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      IFS=$'\n\t'
      nohup "@out@/libexec/i3lock-foreground-wrapper.sh" >>~/.xsession-errors 2>&1 &
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

  src = pkgs.fetchFromGitLab {
    domain = "salsa.debian.org";
    owner = "debian";
    repo = "i3lock-fancy";
    rev = "372fab9210a649f8d4fd14621882b34053da946e";
    sha256 = "0k44hifydf65fw1lyfv95dfmib0vhwaycwc3k41s11ajgzyc9w51";
  };

  buildInputs = [makeWrapper i3lock-color xorg.xset keyboard-layout];
  runtimeDependencies = [i3lock-color xorg.xset xautolock libnotify keyboard-layout];
  phases = ["unpackPhase" "installPhase"];
  installPhase = ''
    mkdir -p "$out/libexec"
    substituteAll "${foregroundWrapper}" "$out/libexec/i3lock-foreground-wrapper.sh"
    chmod +x "$out/libexec/i3lock-foreground-wrapper.sh"

    mkdir -p "$out/bin"
    substituteAll "${wrapper}" "$out/bin/i3lock"
    sed \
      -e "s,\<i3lock\> ,${i3lock-color}/bin/i3lock-color ,g" \
      -e "s,^ICON=.*,ICON=$out/share/i3lock/i3lock-fancy/lock.png," \
        lock >$out/bin/i3lock-fancy
    chmod +x "$out/bin/i3lock" "$out/bin/i3lock-fancy" 

    mkdir -p $out/share/Xresources.d
    install -m 644 "${resources}" $out/share/Xresources.d/i3lock

    mkdir -p $out/share/i3lock/i3lock-fancy
    install -m 644 "${readme}" $out/share/i3lock/README.md
    install -m 644 lock.png LICENSE README.md $out/share/i3lock/i3lock-fancy
  '';
}
