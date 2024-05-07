self: super:
let
  version = "24.05.05";
in
{
  goldendict-ng = super.goldendict-ng.overrideAttrs (
    attrs: {
      version = version;

      src = super.fetchFromGitHub {
        owner = "xiaoyifang";
        repo = "goldendict-ng";
        rev = "v${version}-LiXia.ecd1138c";
        sha256 = "sha256-XMsbI5qqDsunMLlzg8f5aaY+PY6NzO9UMN+Oy1Bt5ls=";
        fetchSubmodules = true;
      };

      buildInputs = attrs.buildInputs ++ [ super.qt6.qtwayland ];
    }
  );
}
