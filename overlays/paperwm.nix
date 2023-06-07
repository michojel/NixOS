self: super:
let
  version = "v44.1.1";
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
          hash = "sha256-JLk7Uy9ZrAinoP+u8SRW4A7GyM0Zk2Fkndm/54bBSCc=";
        };
      }
    );
  };
}
