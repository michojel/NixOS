with import <nixpkgs> {};

let
  xminadBaseDir  = ~/wsp/my/xminad;
  scriptsBaseDir = ~/wsp/my/kmyimport;
  patchesDir     = ~/.config/nixpkgs;
in {
  packageOverrides = pkgs: with pkgs;
    ((import ./ocp4.nix {}).packageOverrides pkgs) //
    ((import ./okd3.nix {}).packageOverrides pkgs) //
    ((import ./helm.nix {}).packageOverrides pkgs) //
    ((import ./operator-framework.nix {}).packageOverrides pkgs) // {
      "w3" = import ./w3.nix {};

      chromium-wrappers = import ./chromium-wrappers.nix {};
    };

  allowUnfree = true;
}

# ex: set et ts=2 sw=2
