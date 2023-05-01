self: super:

let
  version = "2.1.62";
  pname = "anki-bin";

  unpacked = super.stdenv.mkDerivation {
    inherit pname version;

    nativeBuildInputs = [ super.zstd ];
    src = super.fetchurl {
      url = "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-linux-qt6.tar.zst";
      sha256 = "sha256-vsuR+pDqjPGejlxrDPCxKVnvTilRDGGhMDDKSQhVxVQ=";
    };

    installPhase = ''
      runHook preInstall

      xdg-mime () {
        echo Stubbed!
      }
      export -f xdg-mime

      PREFIX=$out bash install.sh

      runHook postInstall
    '';

  };
in
{
  anki-bin = super.buildFHSUserEnv (super.appimageTools.defaultFhsEnvArgs // {
    name = "anki";

    targetPkgs = pkgs: (with pkgs; [ xorg.libxkbfile krb5 ]);

    runScript = super.writeShellScript "anki-wrapper.sh" ''
      export ANKI_WAYLAND=1
      exec ${unpacked}/bin/anki
    '';

    extraInstallCommands = ''
      mkdir -p $out/share
      cp -R ${unpacked}/share/applications \
        ${unpacked}/share/man \
        ${unpacked}/share/pixmaps \
        $out/share/
    '';

    meta = with super.lib; {
      inherit (super.anki.meta) license homepage description longDescription;
      platforms = [ "x86_64-linux" ];
      maintainers = with maintainers; [ atemu ];
    };
  });
}
