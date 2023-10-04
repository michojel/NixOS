self: super:
let
  version = "v44.11.2";
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
          hash = "sha256-TliBkQ3O0p2t8Vf1S5lxS9zr9px8Djzh7AwgmKa/R8k=";
        };

        installPhase = ''
          runHook preInstall

          mkdir -p "$out/share/gnome-shell/extensions/paperwm@paperwm.github.com"
          cp -r . "$out/share/gnome-shell/extensions/paperwm@paperwm.github.com"

          runHook postInstall
        '';
        passthru.extensionUuid = "paperwm@paperwm.github.com";
      }
    );
  };
}
