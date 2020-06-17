{ pkgs ? import <nixpkgs> {}
, version ? "4.2.33"
, ...
}:
let
  ver2sha = pkgs.lib.importJSON ./ocp4-releases.json;

  mkocpdev = binsuffix: sha256: deps: (
    with pkgs; stdenv.mkDerivation {
      version = "${version}";
      name = "openshift-${binsuffix}-${version}";
      meta = with stdenv.lib; {
        description = "OCP 4 ${binsuffix}";
        homepage = https://cloud.redhat.com/openshift/install;
        license = licenses.gpl3Plus;
        platforms = platforms.linux;
      };
      src = fetchurl {
        url = "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}/openshift-${binsuffix}-linux-${version}.tar.gz";
        sha256 = sha256;
      };
      phases = [ "unpackPhase" "installPhase" ];
      runtimeDependencies = deps;
      unpackPhase = ''
        tar -xvf "$src"
      '';
      installPhase = ''
        mkdir -p "$out/bin" "$out/share/openshift-${binsuffix}"
        find -type f -executable | xargs -n 1 -i install -m 755 "{}" "$out/bin/{}"
        for bin in $out/bin/*; do
          if readelf -l "''${bin}" | grep -qi 'program interpreter'; then
            patchelf --set-interpreter \
                    "${stdenv.glibc}/lib/ld-linux-x86-64.so.2" "''${bin}"
          fi
          if readelf -d "''${bin}" | grep -qi 'Dynamic section at offset'; then
            patchelf --set-rpath "${stdenv.glibc}/lib" "''${bin}"
          fi
        done
        install -m 644 README.md "$out/share/openshift-${binsuffix}/README.md"
      '';
    }
  );
in
{

  packageOverrides = pkgs: with pkgs; {
    ocp4 = rec {
      openshift-client = mkocpdev "client" ver2sha."${version}".client [];
      openshift-install = mkocpdev "install" ver2sha."${version}".install [];
    };
  };
}

# ex: set et ts=2 sw=2 :
