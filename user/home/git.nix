{ config, pkgs, lib, ... }:
let
  # TODO: don't assume we run on NixOS
  systemConfig = (import <nixpkgs/nixos> { system = config.nixpkgs.system; }).config;
in
{
  programs = {
    git = {
      enable = true;
      userName = "Michal Minář";
      signing.signByDefault = true;
      delta.enable = true;
      ignores = [
        "bin/"
        "*~"
        "*.bak"
        ".direnv"
        ".envrc"
        ".exrc"
        ".go/"
        ".kube/"
        "*.orig"
        "*.swp"
      ];
      extraConfig = {
        core = {
          # print unicode charaters in file names
          # see https://stackoverflow.com/a/34549249
          quotePath = false;
        };
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "main";
        };
      };
      package = pkgs.gitAndTools.gitFull;
    } // (
      if systemConfig.profile.work.primary then {
        userEmail = "michal.minar@id.ethz.ch";
        signing.key = "0xD4B51B38578238D3";
      } else {
        userEmail = "mm@michojel.cz";
        signing.key = "0xCC8A9A5E76CA611F";
      }
    );

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };

    gitui.enable = true;
  };
}
