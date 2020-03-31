# See:
# - https://nixos.wiki/wiki/Overlays
# - https://gitlab.com/samueldr/nixos-configuration/blob/3febd83b15210282d6435932944d426cd0a9e0ca/modules/overlays-compat/overlays.nix
self: super: with super.lib;
let
  # Using the nixos plumbing that's used to evaluate the config...
  eval = import <nixpkgs/nixos/lib/eval-config.nix>;
  # Evaluate the config,
  paths = (eval { modules = [ (import <nixos-config>) ]; })
  # then get the `nixpkgs.overlays` option.
  .config.nixpkgs.overlays;
in
foldl' (flip extends) (_: super) paths self
