self: super:
let
  version = "4.3.9.0";
  srcFlavor = "Win";
in
{
  megasync = super.megasync.overrideAttrs (
    attrs: {
      version = version;

      src = super.fetchFromGitHub {
        owner = "meganz";
        repo = "MEGAsync";
        rev = "v${version}_${srcFlavor}";
        sha256 = "0lnm71hcda0lljfs12p8zw78d8a6xfb5xg5q9vxf2dsvgyniqq4p";
        fetchSubmodules = true;
      };

      buildInputs = attrs.buildInputs ++ [ super.qt514.qtx11extras ];
    }
  );
}
