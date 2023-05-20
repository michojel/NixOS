self: super:
let
  version = "v43.1.1";
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
          hash = "sha256-k+2Cas+owbxLRjZ+wQQR1XoTtHXoSQjkaC4mfl0ZXRg=";
        };
      }
    );
  };
}
