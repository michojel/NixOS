with import <nixpkgs> {};

let
  xminadBaseDir = ~/wsp/my/xminad;
  patchesDir    = ~/.config/nixpkgs;
in {
  packageOverrides = pkgs: with pkgs; {
    xminad = import "${xminadBaseDir}/default.nix" {};

    i3lock-wrapper = import ./i3lock-wrapper.nix {};

    chromium-wrappers = import ./chromium-wrappers.nix {};

    keyboard-layout = import ./vok-keyboard-layout.nix {};
  };

  allowUnfree = true;
}

