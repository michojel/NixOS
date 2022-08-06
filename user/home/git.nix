{ config, pkgs, lib, ... }:

{
  programs = {
    git = {
      enable = true;
      userName = "Michal Minář";
      userEmail = "mm@michojel.cz";
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
      };
      package = pkgs.gitAndTools.gitFull;
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };

    gitui.enable = true;
  };
}
