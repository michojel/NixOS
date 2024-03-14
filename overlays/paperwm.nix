self: super:
let
  version = "v45.12.1";
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
          hash = "sha256-N8lqz0u+Y3oc/yU6BV8GfE4fUj30t0MEGYdrqswVYYU=";
        };
      }
    );
  };
}
