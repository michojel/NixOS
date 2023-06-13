self: super:
let
  version = "v44.2.0";
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
          hash = "sha256-gvQeOrvLzYIl6MyPG9pXrgSMV9J1GX+ulzRBwbw0L0k=";
        };
      }
    );
  };
}
