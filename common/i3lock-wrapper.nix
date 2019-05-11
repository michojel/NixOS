{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, killer ? ""
, notifier ? ""
, locker ? ""
, keyboard-layout ? import ./keyboard-layout.nix {}
, ... }:

with pkgs;
let
  foregroundWrapper = writeTextFile {
    name = "foreground-wrapper.sh";
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      function revert() {
        # restore dpms to original state
        "${xorg.xset}/bin/xset" dpms 0 0 0
      }
      trap revert HUP INT TERM EXIT
      "${keyboard-layout}/bin/load-keyboard-layout.sh"
      # seconds to wait before standby, suspend and off
      # 0 means never
      # off makes the restoration of monitors unreliable
      "${xorg.xset}/bin/xset" +dpms dpms 10 0 0
      "@out@/bin/i3lock-fancy" "$@"
    '';
  };
  wrapper = writeTextFile {
    name = "wrapper.sh";
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      nohup systemd-cat -t "i3lock-wrapper" "@out@/libexec/i3lock-foreground-wrapper.sh" "$@" >>/dev/null 2>&1 &
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

  runtimeDependencies = [
    fontconfig
    i3lock-color
    imagemagick
    keyboard-layout
    libnotify
    scrot
    utillinux
    xautolock
    xorg.xrandr
    xorg.xset
  ];

  phases = ["unpackPhase" "installPhase"];
  installPhase = let
    args= lib.concatStringsSep " " [
      "--keylayout" "0" "--layoutcolor=FFFFFFFF"
      "--clock" "--timecolor=FFFFFFFF" "--datecolor=FFFFFFFF"
    ];
  in ''
    mkdir -p "$out/libexec"
    substituteAll "${foregroundWrapper}" "$out/libexec/i3lock-foreground-wrapper.sh"
    chmod +x "$out/libexec/i3lock-foreground-wrapper.sh"

    mkdir -p "$out/bin"
    substituteAll "${wrapper}" "$out/bin/i3lock"
    sed \
      -e "s,\<i3lock\> ,${i3lock-color}/bin/i3lock-color ${args} ,g" \
      -e "s,^ICON=.*,ICON=$out/share/i3lock/i3lock-fancy/lock.png," \
        lock >$out/bin/i3lock-fancy
    chmod +x "$out/bin/i3lock" "$out/bin/i3lock-fancy" 

    # TODO: generate the PATH from runtime dependency list
    pth="${bash}/bin:${gawk}/bin:${imagemagick}/bin"
    pth+=":${fontconfig}/bin:${utillinux}/bin:${scrot}/bin"
    pth+=":${xorg.xrandr}/bin"
    wrapProgram "$out/bin/i3lock-fancy" \
      --suffix-each PATH : "''${pth}"

    mkdir -p $out/share/i3lock/i3lock-fancy
    install -m 644 lock.png LICENSE README.md $out/share/i3lock/i3lock-fancy
  '';
}
