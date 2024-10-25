self: super:

let
  unstable = import <nixos-unstable> { };
in
{
  manta = unstable.rustPlatform.buildRustPackage rec {
    pname = "manta";
    version = "v1.52.2";

    src = super.fetchFromGitHub {
      owner = "eth-cscs";
      repo = pname;
      rev = version;
      sha256 = "sha256-2ODFFbMUTVnEJIuK6F26IeIdW62k4DRVZcPFM02a3q8=";
    };

    cargoHash = "sha256-Qcw8Na3XMfAxjqrUbUO88ZJH46oY9tAfS0T5kclMwwk=";

    cargoPatches = [
      # a patch file to add/update Cargo.lock in the source code
      ./deps/manta/Cargo.lock.patch
    ];

    nativeBuildInputs = [ super.perl ];
    buildInputs = [ super.openssl ];

    meta = with super.stdenv.lib; {
      description = "Another CLI for Alps";
      homepage = "https://eth-cscs.github.io/manta/";
      license = super.lib.licenses.bsd3;
      maintainers = [ super.maintainers.michojel ];
    };
  };
}
