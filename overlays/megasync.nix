self: super:
let
  version = "4.9.0.0";
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
        sha256 = "sha256-s0E8kJ4PJmhaxVcWPCyCk/KbcX4V3IESdZhSosPlZuM=";
        fetchSubmodules = true;
      };

      buildInputs = attrs.buildInputs;
    }
  );
}
