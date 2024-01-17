self: super:
let
  version = "v45.8.1";
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
          hash = "sha256-UGk6ggcptCI2aZF3HYL+gYYcjRbhb/ZGUubKPonhdww=";
        };
      }
    );
  };
}
