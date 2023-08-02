self: super:
let
  version = "v44.7.0";
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
          hash = "sha256-0o6pRUUDNyuxIwqrBAw3ecfd6yqUfXAP1s+JvmJLge0=";
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
