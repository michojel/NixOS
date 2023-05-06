{ config, pkgs, lib, ... }:
let
  # TODO: don't assume we run on NixOS
  systemConfig = (import <nixpkgs/nixos> { system = config.nixpkgs.system; }).config;
in
{
  home.shellAliases = {
    gl =
      let
        fmt = lib.concatStringsSep " " [
          ''%C(brightyellow)%h%C(reset) %G? %C(bold brightblue)%an%C(reset)''
          ''%s%C(bold brightcyan)%d%C(reset) %C(brightgreen)%cr.%C(reset)''
        ];
      in
      ''git log --graph --abbrev-commit --pretty=format:"${fmt}" -n 15'';
  };
  programs = {
    git = {
      enable = true;
      userName = "Michal Minář";
      diff-so-fancy.enable = true;
      aliases = {
        co = "checkout";
        root = "rev-parse --show-toplevel";
      };
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
        diff = {
          colorMoved = "zebra";
        };
        merge = {
          tool = "vimdiff";
        };
        fetch = {
          prune = "true";
        };
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
        signing = {
          signByDefault = true;
          key = "0xD4B51B38578238D3";
        };
      } else {
        userEmail = "mm@michojel.cz";
        signing = {
          signByDefault = true;
          key = "0xCC8A9A5E76CA611F";
        };
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
