self: super:
let
  version = "v45.12.2";
in
{
  gnomeExtensions = super.gnomeExtensions // {
    paperwm = super.gnomeExtensions.paperwm.overrideAttrs (
      attrs: {
        inherit version;
        src = super.fetchFromGitHub {
          owner = "paperwm";
          repo = "PaperWM";
          rev = version;
          hash = "sha256-U6dDjit7kSfUryshyiIQRQ8H8sN/XsED6zcGc239RHs=";
        };
      }
    );
  };
}
