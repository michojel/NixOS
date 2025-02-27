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
      lfs.enable = true;
      userName = "Michal Minář";
      diff-so-fancy.enable = true;
      aliases = {
        co = "checkout";
        root = "rev-parse --show-toplevel";

        # https://stackoverflow.com/a/67672350
        main-branch = ''!f() {
            local msg="$(git symbolic-ref refs/remotes/origin/HEAD 2>&1)"
            if echo "''${msg:-}" | grep -q 'refs/remotes/origin/HEAD is not a symbolic ref'; then
              git remotesh >&2 && f;
            else
              echo "''${msg:-}" | cut -d'/' -f4;
            fi
          }; f
        '';
        remotesh = "remote set-head origin --auto";
        # if this fails, one might need to update symbolic reference, e.g.:
        #   git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
        com = ''!f() { git checkout "$(git main-branch)" "$@"; }; f'';
        upm = ''!f() { git pull --rebase --autostash origin "$(git main-branch)" "$@"; }; f'';
        rebasem = ''!f(){ git rebase -i --autosquash "origin/$(git main-branch)" --no-verify "$@"; }; f'';
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
        "shell.nix"
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
