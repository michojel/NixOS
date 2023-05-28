self: super:
let
  version = "v44.0.1";
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
          hash = "sha256-r0sCRMxhTzg91rlP2DOuPBPlLA/BGcr4YfOKhwwPJoU=";
        };
      }
    );
  };
}
