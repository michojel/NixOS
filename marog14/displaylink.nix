{ config, lib, pkgs, modulesPath, ... }:

{
  nixpkgs = {
    overlays =
      [
        (self: super: ({

          displaylink =
            let
              pname = "displaylink";
              version = "5.8";
              long_version = "${version}.0";
              release = "63.33";
              full_version = "${long_version}-${release}";
            in
            super.displaylink.overrideAttrs
              (
                attrs: {
                  inherit version;
                  name = "${pname}-${version}";

                  src = super.requireFile rec {
                    name = "displaylink-${version}.zip";
                    sha256 = "05m8vm6i9pc9pmvar021lw3ls60inlmq92nling0vj28skm55i92";

                    message = ''
                      In order to install the DisplayLink drivers, you must first
                      comply with DisplayLink's EULA and download the binaries and
                      sources from here:

                      https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu-5.8

                      Once you have downloaded the file, please use the following
                      commands and re-run the installation:

                      mv \$PWD/"DisplayLink USB Graphics Software for Ubuntu5.8-EXE.zip" \$PWD/${name}
                      nix-prefetch-url file://\$PWD/${name}
                    '';
                  };

                  unpackPhase = ''
                    unzip $src
                    chmod +x displaylink-driver-${full_version}.run
                    ./displaylink-driver-${full_version}.run --target . --noexec --nodiskspace
                  '';
                }
              );
        }))
      ];
  };
}





