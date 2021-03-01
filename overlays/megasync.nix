self: super:
let
  version = "4.4.0.0";
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
        sha256 = "1xggca7283943070mmpsfhh7c9avy809h0kgmf7497f4ca5zkg2y";
        fetchSubmodules = true;
      };

      buildInputs = attrs.buildInputs ++ [ super.qt514.qtx11extras ];
    }
  );
}
