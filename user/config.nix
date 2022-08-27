with import <nixpkgs> { };
let
  patchesDir = ~/.config/nixpkgs;
in
{
  packageOverrides = pkgs: with pkgs;
    ((import ./operator-framework.nix { }).packageOverrides pkgs) // {
      chrome-wrappers = import ./chrome-wrappers.nix {
        homeDir = "/home/michojel";
      };
      #firefox-wrappers = import ./firefox-wrappers.nix { };
      "w3" = import ./w3.nix { };
    };
  allowUnfree = true;
}

# ex: set et ts=2 sw=2
