{ pkgs ? import <nixpkgs> {}
, version ? "4.1.18"
, ... }:

let
  ver2sha = {
    "4.1.18" = {
      client = "0sd9mmpam8a53a21hfgg6h70zyilmw646rgrxi1i39h400sfi9dd";
      install = "0hby4gilpp684mbmdwis10i517hs0j42l6xg9glklnd9r2agjm35";
    };
    "4.1.8" = {
      client  = "1l3xp133zc27ypsp362nm9jsjhr1bbrhk3axd3jiffifc4075asn";
      install = "0zmlwyjzggr6p4acfr8bfmbqxsiv1b9jjav8ja0lxrcr774qlddf";
    };
    "4.1.7" = {
      client  = "0sswf5p6kdk241yn8s4n981c37d5z6349lac2i2hixjwbq957nl8";
      install = "06n23p4pn8j80p4g77fmjynin4g96m4fhw8gv8wd0kyvgwkaai6q";
    };
    "4.1.6" = {
      client  = "17fn6p44jmkswi9f7zxcbd28rhxha6wnwc4zsbng7nqjhyqwm9lg";
      install = "18zksra3fqam2p93v61br23w00cyggncbhf3i1wi0bhl9prbdgi8";
    };
    "4.1.4" = {
      client  = "08qrw1nw5wbvdm3hb6c69kqqlhdfkw83smk4rzga6w2mpzvv0j20";
      install = "0djr5grdqbf0fs985253h0xcda5v2bc9wsbhnqlnkaaxbaakgbjm";
    };
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
      phases = ["unpackPhase" "installPhase"];
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
