self: super:
let
  version = "4.11.0.0";
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
        sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        fetchSubmodules = true;
      };

      buildInputs = attrs.buildInputs;
    }
  );
}
