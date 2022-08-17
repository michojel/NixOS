with import <nixpkgs> { };
let
  xminadBaseDir = ~/wsp/my/xminad;
  scriptsBaseDir = ~/wsp/my/kmyimport;
  patchesDir = ~/.config/nixpkgs;
in
{
  packageOverrides = pkgs: with pkgs;
    ((import ./helm.nix { }).packageOverrides pkgs) //
    ((import ./ocp4.nix { }).packageOverrides pkgs) //
    ((import ./okd3.nix { }).packageOverrides pkgs) //
    ((import ./operator-framework.nix { }).packageOverrides pkgs) // {
      chromium-wrappers = import ./chromium-wrappers.nix { };
      firefox-wrappers = import ./firefox-wrappers.nix { };
      "w3" = import ./w3.nix { };
    };

  allowUnfree = true;
}

# ex: set et ts=2 sw=2
