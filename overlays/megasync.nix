self: super:
let
  version = "4.12.2.0";
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
        sha256 = "sha256-Rl9/Y+Ll7nq6v92ca6phRilo/DpwunMbp/436rgyi2g=";
        fetchSubmodules = true;
      };

      buildInputs = attrs.buildInputs;
      configureFlags = [
        "--disable-examples"
        "--disable-java"
        "--disable-php"
        "--enable-chat"
        "--with-cares"
        "--with-cryptopp"
        "--with-curl"
        "--with-ffmpeg"
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
