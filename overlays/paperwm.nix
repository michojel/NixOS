self: super:
let
  version = "v44.3.1";
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
          hash = "sha256-oGBnQGtx2ku4cfgZkZ3OdHlVuiYR8hy1eYDWDZP3fn4=";
        };
      }
    );
  };
}
