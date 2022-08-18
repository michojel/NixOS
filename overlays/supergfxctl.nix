# inspired by https://github.com/NixOS/nixpkgs/pull/147786
# kudos to Rasmus Thomsen (Cogitri on GitHub)
self: super:

{
  supergfxctl = super.rustPlatform.buildRustPackage rec {
    pname = "supergfxctl";
    version = "4.0.5";

    src = super.fetchFromGitLab {
      owner = "asus-linux";
      repo = pname;
      rev = version;
      sha256 = "sha256-hdHZ1GNhEotyOOPW3PJMe4+sdTqwic7iCnVsA5a1F1c=";
    };

    patches = [
      #./no-config-write.patch
    ];

    postPatch = ''
      substituteInPlace data/supergfxd.service \
        --replace /usr/bin $out/bin
      substituteInPlace src/controller.rs \
        --replace \"modprobe\" \"${super.kmod}/bin/modprobe\" \
        --replace \"rmmod\" \"${super.kmod}/bin/rmmod\"
    '';

    nativeBuildInputs = [ super.pkg-config ];
    buildInputs = [ super.udev ];

    buildFeatures = [ "daemon" "cli" ];

    cargoHash = "sha256-+D/4cDMp6bwyavbfFO7RAFPTmbizS3+5qr6sJzA5JiE=";

    postInstall = ''
      make install INSTALL_PROGRAM=true DESTDIR=$out prefix=
    '';

    #makeFlags = [ "prefix=" ];

    meta = with super.lib; {
      description = "Graphics switching tool";
      homepage = "https://gitlab.com/asus-linux/supergfxctl";
      license = licenses.mpl20;
      maintainers = [ maintainers.Cogitri ];
    };
  };
}
