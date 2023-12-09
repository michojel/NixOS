self: super:
let
  version = "unstable-2023-11-10";
in
{
  gnomeExtensions = super.gnomeExtensions // {
    pop-shell = super.gnomeExtensions.pop-shell.overrideAttrs (
      attrs: {
        version = version;

        src = super.fetchFromGitHub {
          owner = "pop-os";
          repo = "shell";
          rev = "aafc9458a47a68c396933c637de00421f5198a2a";
          sha256 = "sha256-74lZbEYHj7fufRSbuI2SN9rqbB3gpRa0V96qjAFc01s=";
          fetchSubmodules = true;
        };
      }
    );
  };
}
