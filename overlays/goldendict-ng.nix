self: super:
let
  version = "24.09.0";
in
{
  goldendict-ng = super.goldendict-ng.overrideAttrs (
    attrs: {
      version = version;

      src = super.fetchFromGitHub {
        owner = "xiaoyifang";
        repo = "goldendict-ng";
        rev = "v${version}-Release.316ec900";
        sha256 = "sha256-m2sggMF+KKX4Nhb4BAb7uQdIxxv1PPRRO/+8FH3Vdj8=";
        fetchSubmodules = true;
      };

      buildInputs = attrs.buildInputs ++ [ super.qt6.qtwayland ];
    }
  );
}
