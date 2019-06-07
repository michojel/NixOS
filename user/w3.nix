{ pkgs ? import <nixpkgs> {}, ... }:

with pkgs;
let
  native-client-user-service = writeTextFile {
    name = "browser-app-launcher.service";
    text = ''
      [Unit]
      Description = "Registers native-client withit browsers"

      [Service]
      Type             = oneshot
      WorkingDirectory = @out@/libexec/native-client/linux/app
      ExecStart        = ${nodejs}/bin/node install.js

      [Install]
      WantedBy = graphical-session.target
    '';
  };

  browser-app-launcher-client-register = writeTextFile {
    name = "browser-app-launcher-client-register.sh";
    text = ''
      #!/usr/bin/env bash

      set -euo pipefail
      IFS=$'\n\t'
      cd @out@/libexec/native-client/linux/app
      exec ${nodejs}/bin/node install.js
    '';
  };

in stdenv.mkDerivation {
  name = "w3";
  version = 0.2;
  meta = with stdenv.lib; {
    description = "Web browser launcher.";
    longDescription = ''
      Just for private use by miminar at redhat dot com.
    '';
    homepage = https://gitlab.corp.redhat.com/miminar/w3;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
#  src = if (exists ~/wsp/my/w3/w3) then
#    ~/wsp/my/w3/w3
#  else
#    fetchFromGitLab {
#      https:///World/podcasts/uploads/e59ac5d618d7daf4c7f33ba72957c466/gnome-podcasts-0.4.6.tar.xz
#    }
  srcs = [
    ~/wsp/my/w3
    (fetchFromGitHub {
        owner = "andy-portmen";
        repo = "native-client";
        #tag = "0.7.0";
        #release = "0.7.0";
        #commit = "2ca6bf3b837e160270e9641bddda4eb5ed732dfb";
        rev = "0.7.0";
        sha256 = "0l679jr5vhlg7wvd0pdx85k6lv25abx0fzahc3vxv0ssyzw45si7";
      })
  ];

  buildInputs = [makeWrapper chromium firefox firefox-esr imagemagick nodejs];
  runtimeDependencies = [
    chromium
    firefox
  ];
  phases = ["unpackPhase" "installPhase"];
  sourceRoot = ".";
  installPhase = ''
    mkdir -p "$out/bin"
    pushd w3
      sed \
        -e "s,/usr/bin/env bash,${pkgs.bash}/bin/bash," \
        -e 's,"firefox","'"${pkgs.firefox}/bin/firefox"'",g' \
          "w3" >$out/bin/w3
      chmod +x $out/bin/w3

      mkdir -p "$out/share/applications"
      install -m 0644 config/w3.desktop "$out/share/applications"

      make -C data install DESTDIR=$out/share/icons/hicolor
    popd

    pushd source/
      mkdir -p $out/libexec/native-client
      cp -a *.js linux $out/libexec/native-client/
      # node install.js --custom-dir=$out/libexec
    popd

    mkdir -p $out/lib/systemd/user
    substituteAll "${native-client-user-service}" \
        "$out/lib/systemd/user/browser-app-launcher.service"
    chmod +x "$out/lib/systemd/user/browser-app-launcher.service"

    mkdir -p $out/bin
    substituteAll "${browser-app-launcher-client-register}" \
        "$out/bin/browser-app-launcher-client-register.sh"
    chmod +x "$out/bin/browser-app-launcher-client-register.sh"
  '';
}
