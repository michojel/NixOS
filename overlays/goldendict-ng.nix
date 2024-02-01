self: super:
let
  version = "v24.01.22-LoongYear.3dddb3be";
in
{
  goldendict-ng = super.goldendict-ng.overrideAttrs (
    attrs: {
      version = version;

      src = super.fetchFromGitHub {
        owner = "xiaoyifang";
        repo = "goldendict-ng";
        rev = "${version}";
        sha256 = "sha256-/+BoNx/t4rGiDiQdqDNcpKJ/NwLZaIbCeEhwa3JlxpQ=";
        fetchSubmodules = true;
      };

      buildInputs = attrs.buildInputs ++ [ super.qt6.qtwayland ];
    }
  );
}
