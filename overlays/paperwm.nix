self: super:
let
  version = "v46.17.1";
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
          hash = "sha256-RnmXbfO+IjBJkoLKsBaNa7FAfUa4w/Q6uEaqCjqlNic=";
        };
      }
    );
  };
}
