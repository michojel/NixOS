self: super:
let
  version = "v44.1.0";
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
          hash = "sha256-J3yaq8dy3v9bZAoJu0ww305eSZvRzwP5SFkTf/hRPMg=";
        };
      }
    );
  };
}
