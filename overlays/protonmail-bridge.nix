self: super:
{
  #  protonmail-bridge = let
  #    version = "1.2.6-1";
  #  in super.protonmail-bridge.overrideAttrs (
  #    attrs: let pbsuper = super.protonmail-bridge; in {
  #      inherit version;
  #      src = super.fetchurl {
  #        url = "https://protonmail.com/download/protonmail-bridge_${version}_amd64.deb";
  #        sha256 = "0iy2x9qnvhqrv6df0mjmxss9jddd64gh8wbadkn0cvrczcbwkz9l";
  #      };
  #
  #      installPhase = with super.lib; concatStringsSep "\n" (
  #        filter
  #          # the svg icon is now installed to the right location - no need for
  #          # the extra copy
  #          (l: builtins.match "cp.*protonmail.*\\.svg$" l == null)
  #          (splitString "\n" pbsuper.installPhase)
  #      );
  #    }
  #  );

  protonmail-bridge = let
    version = "1.2.3-1";
  in super.protonmail-bridge.overrideAttrs (
    attrs: let pbsuper = super.protonmail-bridge; in {
      inherit version;
      src = super.fetchurl {
        url = "https://protonmail.com/download/protonmail-bridge_${version}_amd64.deb";
        sha256 = "032ggk9fvd19fbsqkzwzwh0hpyg8gpkrin71di7zsx6ias5innw1";
      };

      installPhase = ''
        mkdir -p $out/{bin,lib,share}

        cp -r usr/lib/protonmail/bridge/protonmail-bridge $out/lib
        cp -r usr/share $out

        ln -s $out/lib/protonmail-bridge $out/bin/protonmail-bridge
      '';
    }
  );
}
