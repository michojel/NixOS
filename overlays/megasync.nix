self: super:
let
  version = "4.5.3.0";
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
        sha256 = "1lwjmdbqyxx5wd8nx4mc830fna37jad4h93viwfh5x7sxn104js7";
        fetchSubmodules = true;
      };

      buildInputs = attrs.buildInputs;
    }
  );
}
