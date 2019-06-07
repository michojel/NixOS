{ pkgs ? import <nixpkgs> {}
, version ? "4.1.0"
, ... }:

let
  ver2sha = {
    "4.1.0" = {
      client  = "054zd7qw1kdykscnc6v55bn9fgjws50kx9p0p7b2jy5mf1pjq4w4";
      install = "15wmjgk4irs1krmx26vh5rxghfbqlvdkdi08m2pj7d7gdd161wvp";
    };
    "4.1.0-rc.7" = {
      client  = "84132c6f70b57829d6b9e0a63e41d15c3e97ec2a651b66999ebecdc0f1699f14";
      install = "92ea50f40741f58d3739d1d1e627d5a6e38f3e9bac81812030452626ff4c7b0b";
    };
  };

  mkocpdev = binsuffix: sha256: deps: (with pkgs; stdenv.mkDerivation {
      name = "openshift-${binsuffix}";
      version = "${version}";
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
      phases = ["unpackPhase" "installPhase"];
      runtimeDependencies = deps;
      unpackPhase = ''
        tar -xvf "$src"
      '';
      installPhase = ''
        mkdir -p "$out/bin" "$out/share/openshift-${binsuffix}"
        find -type f -executable | xargs -n 1 -i install -m 755 "{}" "$out/bin/{}"
        for bin in $out/bin/*; do
          patchelf --set-interpreter \
                  "${stdenv.glibc}/lib/ld-linux-x86-64.so.2" "''${bin}"
          patchelf --set-rpath "${stdenv.glibc}/lib" "''${bin}"
        done
        install -m 644 README.md "$out/share/openshift-${binsuffix}/README.md"
      '';
    });

in {

  packageOverrides = pkgs: with pkgs; {
    ocp4 = rec {
      openshift-client  = mkocpdev "client"  ver2sha."${version}".client  [];
      openshift-install = mkocpdev "install" ver2sha."${version}".install [];
    };
  };
}

# ex: set et ts=2 sw=2 :
