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

    kmyimport = import "${scriptsBaseDir}/kmyimport.nix" {
      path    = "${scriptsBaseDir}";
    };

    i3lock-wrapper = import ./i3lock-wrapper.nix {};

    chromium-wrappers = import ./chromium-wrappers.nix {};

    keyboard-layout = import ./keyboard-layout.nix {
      xkbLayout  = xkbLayout;
      xkbVariant = xkbVariant;
      xkbOption  = xkbOption;
    };

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
