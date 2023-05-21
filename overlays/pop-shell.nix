self: super:
let
  version = "unstable-2023-04-27";
in
{
  gnomeExtensions = super.gnomeExtensions // {
    pop-shell = super.gnomeExtensions.pop-shell.overrideAttrs (
      attrs: {
        version = version;

        src = super.fetchFromGitHub {
          owner = "pop-os";
          repo = "shell";
          rev = "b5acccefcaa653791d25f70a22c0e04f1858d96e";
          sha256 = "sha256-w6EBHKWJ4L3ZRVmFqZhCqHGumbElQXk9udYSnwjIl6c=";
          fetchSubmodules = true;
        };
      }
    );
  };
}
