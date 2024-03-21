self: super:
let
  version = "5.2.0.0";
  srcFlavor = "Linux";
in
{
  megasync = super.megasync.overrideAttrs (
    attrs: {
      version = version;

      src = super.fetchFromGitHub {
        owner = "meganz";
        repo = "MEGAsync";
        rev = "v${version}_${srcFlavor}";
        sha256 = "sha256-zKDze+5nPxDC/dMjQQLJRGw29hRRBjcgbRUmr++5Kow=";
        fetchSubmodules = true;
      };

      buildInputs = with super; [
        c-ares
        cryptopp
        curl
        #ffmpeg
        libmediainfo
        libraw
        libsodium
        libuv
        libzen
        qt5.qtbase
        qt5.qtx11extras
        qt5.qtwayland
        sqlite
        wget
      ];

      configureFlags = [
        "--disable-examples"
        "--disable-java"
        "--disable-php"
        "--enable-chat"
        "--with-cares"
        "--with-cryptopp"
        "--with-curl"
        "--without-ffmpeg"
        "--without-freeimage"
        "--without-readline"
        "--without-termcap"
        "--with-sodium"
        "--with-sqlite"
        "--with-zlib"
      ];

      patches = [
        # Distro and version targets attempt to use lsb_release which is broken
        # (see issue: https://github.com/NixOS/nixpkgs/issues/22729)
        ./megasync-noinstall-distro-version.patch
        # megasync target is not part of the install rule thanks to a commented block
        ./megasync-install-megasync.patch
      ];
    }
  );
}
