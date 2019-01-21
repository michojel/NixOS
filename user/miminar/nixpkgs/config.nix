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
  };

  allowUnfree = true;
}
