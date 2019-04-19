with import <nixpkgs> {};

let
  xminadBaseDir  = ~/wsp/my/xminad;
  scriptsBaseDir = ~/wsp/my/kmyimport;
  patchesDir     = ~/.config/nixpkgs;

  xkbLayout     = "vok,ru";
  xkbVariant    = ",";
  xkbOption     = "grp:shift_caps_toggle,terminate:ctrl_alt_bksp";
in {
  packageOverrides = pkgs: with pkgs; {
    xminad = import "${xminadBaseDir}/default.nix" {};

    "3w" = import ./3w.nix {};

    kmyimport = import "${scriptsBaseDir}/kmyimport.nix" {
      path    = "${scriptsBaseDir}";
    };

    chromium-wrappers = import ./chromium-wrappers.nix {};

    awless = pkgs.awless.overrideAttrs (old: rec {
      version = "0.1.11";
      src = old.src // {
        rev = "v${verison}";
        sha256 = "187i21yrm10r3f5naj3jl0rmydr5dkhmdhxs90hhf8hjp59a89kg";
      };
   });
  };

  allowUnfree = true;
}

# ex: set et ts=2 sw=2
