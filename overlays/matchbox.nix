self: super: {
  matchbox = let
    version = "0.8.3";
  in super.stdenv.mkDerivation {
    version = "${version}";
    name = "matchbox";
    meta = with super.stdenv.lib; {
      description = "Network boot and provision Container Linux / Fedora CoreOS clusters";
      homepage = https://matchbox.psdn.io/;
      license = licenses.asl20;
      platforms = platforms.linux;
    };
    src = super.fetchurl {
      url = "https://github.com/poseidon/matchbox/releases/download/v${version}/matchbox-v${version}-linux-amd64.tar.gz";
      sha256 = "17m8knysiai31zp5aqx0dirxwackkhkrm0mmj0a9zbr7rj2n46jp";
    };
    phases = [ "unpackPhase" "installPhase" ];
    #runtimeDependencies = deps;
    unpackPhase = ''
      tar -xvf "$src"
    '';
    installPhase = ''
      cd matchbox-v${version}-linux-amd64
      mkdir -p "$out/bin" "$out/share/matchbox"
      mkdir -p "$out/lib/systemd/user/"
      install -m 755 -t "$out/bin" matchbox
      for bin in $out/bin/*; do
        if readelf -l "''${bin}" | grep -qi 'program interpreter'; then
          patchelf --set-interpreter \
                  "${super.stdenv.glibc}/lib/ld-linux-x86-64.so.2" "''${bin}"
        fi
        if readelf -d "''${bin}" | grep -qi 'Dynamic section at offset'; then
          patchelf --set-rpath "${super.stdenv.glibc}/lib" "''${bin}"
        fi
      done
      install -m 644 README.md "$out/share/matchbox/README.md"
      install -m 644 contrib/systemd/matchbox.service "$out/lib/systemd/user/matchbox.service"
      sed -i -e 's,^\(ExecStart=\).*,\1'"$out"'/bin/matchbox,' \
             -e 's,^\(User\|Group\)=,#\0,' \
             -e '/^ExecStart=/i Environment="MATCHBOX_DATA_PATH=%h/.local/lib/matchbox"' \
             -e '/^ExecStart=/i Environment="MATCHBOX_ASSETS_PATH=%h/.local/lib/matchbox/assets"' \
             -e '/^ExecStart=/i ExecStartPre=-${super.coreutils}/bin/mkdir -p "''${MATCHBOX_ASSETS_PATH}"        "''${MATCHBOX_DATA_PATH}/groups"' \
             -e '/^ExecStart=/i ExecStartPre=-${super.coreutils}/bin/mkdir -p "''${MATCHBOX_DATA_PATH}/ignition" "''${MATCHBOX_DATA_PATH}/profiles"' \
        "$out/lib/systemd/user/matchbox.service" 
    '';
  };
}
