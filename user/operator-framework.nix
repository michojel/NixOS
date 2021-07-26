{ pkgs ? import <nixpkgs> { }
, version ? "v0.10.0"
, ...
}:
let
  ver2sha = {
    # TODO: verify asc
    # TODO: update script
    "v0.10.0" = {
      operator-sdk = "034bcb6rfv2d3ifwi3q7ki0b9fsmm1s04s3sa3a8jkmsb5f8zp0q";
    };
  };

  mkderiv = sha256: deps: (with pkgs;
    let
      srcBinName = "operator-sdk-${version}-x86_64-linux-gnu";
      dstBinName = "operator-sdk";
    in
    stdenv.mkDerivation {
      version = "${version}";
      name = "operator-sdk-${version}";
      meta = with lib; {
        description = "Operator Framework SDK";
        homepage = https://github.com/operator-framework/operator-sdk;
        license = licenses.asl20;
        platforms = platforms.linux;
      };
      src = fetchurl {
        url = "https://github.com/operator-framework/operator-sdk/releases/download/${version}/${srcBinName}";
        sha256 = sha256;
      };
      phases = [ "installPhase" ];
      runtimeDependencies = deps;
      installPhase = ''
        mkdir -p "$out/bin" "$out/share/${dstBinName}"
        pushd $out/bin
          install -m 755 "$src" "${dstBinName}"
          if readelf -l "${dstBinName}" | grep -qi 'program interpreter'; then
            patchelf --set-interpreter \
                    "${stdenv.glibc}/lib/ld-linux-x86-64.so.2" "${dstBinName}"
          fi
          if readelf -d "${dstBinName}" | grep -qi 'Dynamic section at offset'; then
            patchelf --set-rpath "${stdenv.glibc}/lib" "${dstBinName}"
          fi
        popd
      '';
    });

in
{
  packageOverrides = pkgs: with pkgs; {
    operator-sdk = mkderiv ver2sha."${version}".operator-sdk [ ];
  };
}

# ex: set et ts=2 sw=2 :
