self: super:
let
  version = "v45.6.0";
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
          hash = "sha256-QEqWZU7FEhAtLvmd2TWUEhGhY4QHHymrS6E6KaNtKBg=";
        };
      }
    );
  };
}
