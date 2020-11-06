self: super:
let
  version = "4.3.5.0";
in
{
  megasync = super.megasync.overrideAttrs (
    attrs: {
      version = version;

      src = super.fetchFromGitHub {
        owner = "meganz";
        repo = "MEGAsync";
        rev = "v${version}_Linux";
        sha256 = "0rr1jjy0n5bj1lh6xi3nbbcikvq69j3r9qnajp4mhywr5izpccvs";
        fetchSubmodules = true;
      };

      buildInputs = attrs.buildInputs ++ [ super.qt514.qtx11extras ];
    }
  );
}
