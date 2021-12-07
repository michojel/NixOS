{ pkgs ? import <nixpkgs> { }, ... }:
let
  # TODO: setup sync to anki.michojel.cz with an addon
  # using e.g. https://github.com/kuklinistvan/docker-anki-sync-server/tree/master/Addon%20for%20AnkiDesktop/SyncRedirector
  panki-launcher = pkgs.stdenv.writeTextFile {
    name = "panki-launcher";
    executable = true;
    text = ''
      #!/usr/bin/env bash
    '';
  };

in
pkgs.stdenv.mkDerivation rec {
  name = "panki";
  version = pkgs.anki.version;
  meta = pkgs.anki.meta // {
    outputsToInstall = [ "out" ];
  };
  nativeBuildInputs = with pkgs; [ makeWrapper anki-bin ];
  #buildInputs = [ moreutils jq ];
  runtimeDependencies = with pkgs; [ anki-bin ];
  phases = [ "installPhase" ];
  #sourceRoot = ".";
  installPhase = ''
    mkdir -p "$out/bin"
    makeWrapper "${pkgs.anki-bin}/bin/anki" "$out/bin/${name}" \
      --add-flags --base=\$HOME/.secret/anki/ \
      --add-flags --profile=private
  '';
}
