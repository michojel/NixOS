{ pkgs ? import <nixpkgs> { }
, version ? "3.11.0"
, ...
}:
let
  ver2sha = {
    "3.11.0" = {
      client = "18qdk78fyhhjklsnqprmm74n8aa0wn3q5qyjb161fm58id10f3sb";
    };
  };

  mkocpdev = binsuffix: sha256: deps: (with pkgs; stdenv.mkDerivation {
    version = "${version}";
    name = "okd-${binsuffix}-${version}";
    meta = with lib; {
      description = "OCP 4 ${binsuffix}";
      homepage = https://cloud.redhat.com/openshift/install;
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
    };
    src = fetchurl {
      url = "https://github.com/openshift/origin/releases/download/v${version}/openshift-origin-${binsuffix}-v${version}-0cbc58b-linux-64bit.tar.gz";
      sha256 = sha256;
    };
    phases = [ "unpackPhase" "installPhase" ];
    runtimeDependencies = deps;
    unpackPhase = ''
      tar -xvf "$src"
    '';
    installPhase = ''
      mkdir -p "$out/bin" "$out/share/okd-${binsuffix}"
      for file in `find -type f -executable`; do
        dest="$out/bin/''$(basename "''${file}")"
        install -m 755 "''$file" "''$dest"
      done
      for bin in $out/bin/*; do
        if readelf -l "''${bin}" | grep -qi 'program interpreter'; then
          patchelf --set-interpreter \
                  "${stdenv.glibc}/lib/ld-linux-x86-64.so.2" "''${bin}"
        fi
        if readelf -d "''${bin}" | grep -qi 'Dynamic section at offset'; then
          patchelf --set-rpath "${stdenv.glibc}/lib" "''${bin}"
        fi
      done
      for file in `find -type f -name "README*"`; do
        dest="$out/share/okd-${binsuffix}/''$(basename "''$file")"
        install -m 644 "''$file" "''$dest"
      done
    '';
  });

in
{

  packageOverrides = pkgs: with pkgs; {
    okd3 = rec {
      client-tools = mkocpdev "client-tools" ver2sha."${version}".client [ ];
    };
  };
}

# ex: set et ts=2 sw=2 :
