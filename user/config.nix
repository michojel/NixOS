with import <nixpkgs> { };
let
  patchesDir = ~/.config/nixpkgs;
in
{
  packageOverrides = pkgs: with pkgs; { };
  allowUnfree = true;
}

# ex: set et ts=2 sw=2
