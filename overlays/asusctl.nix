self: super:

let
  # can't use the latest 4.3.4 because of error "deriving `Default` on enums is experimental"
  # which requires nightly rustc with featuregate #![feature(derive_default_enum)]
  # see https://github.com/rust-lang/rust/pull/86735
  version = "4.2.1";
  unstable = import <nixos-unstable> { };
in
{
  asusctl = unstable.rustPlatform.buildRustPackage rec {
    pname = "asusctl";
    inherit version;
    src = super.fetchFromGitLab {
      owner = "asus-linux";
      repo = pname;
      rev = version;
      sha256 = "sha256-nw4Y5/+pzhRBSiqL8bDSACAYCQeSthPYXunoYiiSi6Y=";
    };
    cargoHash = "sha256-1BGov+xRpRSH3yFjC89PsV1lIVxJfmfcP46UzLJ6eWw=";

    nativeBuildInputs = [ super.pkg-config ];
    buildInputs = [ super.udev ];

    postInstall = ''
      make install INSTALL_PROGRAM=true DESTDIR=$out prefix=
    '';

    meta = {
      description = "Control utility for ASUS ROG";
      longDescription = ''
        asusd is a utility for Linux to control many aspects of various ASUS
        laptops but can also be used with non-asus laptops with reduced features.
      '';
      homepage = "https://asus-linux.org";
      license = super.lib.licenses.mpl20;
      maintainers = with super.lib.maintainers; [ sauricat ];
    };
  };
}
