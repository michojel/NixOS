{ config, lib, pkgs, modulesPath, ... }:

{
  nixpkgs = {
    overlays =
      let
        lpEvdiOverlay = (pkgs: lpself: lpsuper: {
          evdi =
            let
              pname = "evdi";
              version = "1.13.1";
            in
            lpsuper.evdi.overrideAttrs (o: rec {
              inherit version;
              name = "${pname}-${version}";

              src = pkgs.fetchFromGitHub {
                owner = "DisplayLink";
                repo = pname;
                rev = "v${version}";
                sha256 = "sha256-Or4hhnFOtC8vmB4kFUHbFHn2wg/NsUMY3d2Tiea6YbY=";
              };
            }
            );
        });
      in

      [
        (self: super: ({

          linuxPackages = super.linuxPackages.extend (lpEvdiOverlay super);

          linuxPackages_6_1 = super.linuxPackages_6_1.extend (lpEvdiOverlay super);

          displaylink =
            let
              pname = "displaylink";
              version = "5.7";
              arch = with super;
                if stdenv.hostPlatform.system == "x86_64-linux" then "x64"
                else if stdenv.hostPlatform.system == "i686-linux" then "x86"
                else
                  throw
                    "Unsupported architecture";
              bins = "${arch}-ubuntu-1604";

              rules = super.writeTextFile
                {
                  name = "displaylink-rules";
                  text = super.lib.concatStringsSep " " [
                    ''ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb",''
                    ''ATTRS{idVendor}=="17e9", ATTR{bInterfaceClass}=="ff",''
                    ''ATTR{bInterfaceProtocol}=="03", TAG+="systemd", ENV{SYSTEMD_WANTS}="dlm.service"''
                  ];
                };

              libPath = with super; lib.makeLibraryPath
                [
                  stdenv.cc.cc
                  util-linux
                  libusb1
                  self.linuxPackages_6_1.evdi
                ];
            in
            super.displaylink.overrideAttrs
              (
                attrs: {
                  inherit version;
                  name = "${pname}-${version}";

                  src = super.requireFile rec {
                    name = "displaylink-5.7.zip";
                    sha256 = "058mvmldrkzqgd9likxjgkq7gqijpfwr6r423xpirry178h1qzw0";

                    message = ''
                      In order to install the DisplayLink drivers, you must first
                      comply with DisplayLink's EULA and download the binaries and
                      sources from here:

                      https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu-5.6.1

                      Once you have downloaded the file, please use the following
                      commands and re-run the installation:

                      mv \$PWD/"DisplayLink USB Graphics Software for Ubuntu5.6.1-EXE.zip" \$PWD/${name}
                      nix-prefetch-url file://\$PWD/${name}
                    '';
                  };

                  unpackPhase = ''
                    unzip $src
                    chmod +x displaylink-driver-${version}.run
                    ./displaylink-driver-${version}.run --target . --noexec --nodiskspace
                  '';

                  installPhase = with super; ''
                    install -Dt $out/lib/displaylink *.spkg
                    install -Dm755 ${bins}/DisplayLinkManager $out/bin/DisplayLinkManager
                    mkdir -p $out/lib/udev/rules.d $out/share
                    cp ${rules} $out/lib/udev/rules.d/99-displaylink.rules
                    patchelf \
                      --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) \
                      --set-rpath ${libPath} \
                      $out/bin/DisplayLinkManager
                    wrapProgram $out/bin/DisplayLinkManager \
                      --chdir "$out/lib/displaylink"

                    # We introduce a dependency on the source file so that it need not be redownloaded everytime
                    echo $src >> "$out/share/workspace_dependencies.pin"
                  '';
                }
              );
        }))
      ];
  };
}
