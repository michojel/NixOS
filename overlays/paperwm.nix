self: super:
let
  version = "v44.3.0";
in
{
  gnomeExtensions = super.gnomeExtensions // {
    paperwm = super.gnomeExtensions.paperwm.overrideAttrs (
      attrs: {
        pname = "gnome-shell-extension-paperwm";
        inherit version;

        src = super.fetchFromGitHub {
          owner = "paperwm";
          repo = "PaperWM";
          rev = version;
          hash = "sha256-zVxsfoIMTBhd2eXI+mP3FWe68UGiCIh+5RsXBKk16jE=";
        };
      }
    );
  };
}
