{ config, lib, pkgs, ... }:
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in
rec {
  environment = {
    shellInit =
      ''
        for p in .local/bin .cabal/bin bin wsp/go/binaries; do
            p="$HOME/$p"
            if [[ -d "$p" ]] && echo "$PATH" | grep -qvF "$p"; then
                pth="$p:''${pth:-}"
            fi
        done
        export PATH="''${pth:-}$PATH"
        unset p pth
      '';
    shells = [ pkgs.bashInteractive ];
    shellAliases = {
      mux = "tmuxinator";
      minioc = "${pkgs.minio-client}/bin/mc";
      Mc = "${pkgs.minio-client}/bin/mc";
    };
    variables = {
      EDITOR = lib.mkOverride 900 "nvim";
    };

    # essential cli tools
    systemPackages = with pkgs; [
      ack
      aspell
      bc
      bind
      cryptsetup
      curl
      duplicity
      # file deduplication
      fd
      fdupes
      file

      fzf
      vimPlugins.fzfWrapper
      vimPlugins.fzf-vim

      gist
      git
      gitAndTools.git-annex
      gitAndTools.git-annex-remote-rclone
      gitAndTools.git-annex-utils
      gitAndTools.git-hub
      gitAndTools.hub

      # TODO: reduce dependencies to make it X free
      gnupg

      gptfdisk
      htop
      jq
      libxml2
      krb5Full.dev
      mc
      megatools
      minio-client
      moreutils
      ncdu
      neovim
      # for command-not-found.sh
      nix-index
      nixUnstable
      ntp
      parallel
      pciutils
      pinentry
      procps
      psmisc
      pwgen
      putty
      ranger
      ripgrep
      # file deduplication
      rmlint
      sshfs
      silver-searcher
      tmuxinator
      tree
      vim
      unrar
      unzip
      w3m
      wget
      yq

      # for fun
      asciiquarium
      cmatrix
      cowsay
      fortune
      oneko
      sl
      toilet
      tty-clock

      # devel
      shellcheck
    ];
  };

  programs = {
    bash = {
      enableCompletion = true;
      interactiveShellInit =
        ''
          if command -v fzf-share >/dev/null 2>&1; then
            source "$(fzf-share)/key-bindings.bash"
            source "$(fzf-share)/completion.bash"
          fi
        '';
    };
    iotop.enable = true;
    iftop.enable = true;
    command-not-found.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };
    ssh = {
      extraConfig = ''
        AddKeysToAgent confirm
      '';
      startAgent = true;
    };

    tmux = {
      enable = true;
      clock24 = true;
      historyLimit = 10000;
      keyMode = "vi";
      newSession = true;
    };
  };

  security = {
    sudo = {
      extraConfig = ''
        Defaults:root,%wheel  !tty_tickets
        Defaults:root,%wheel  timestamp_timeout = 10
        Defaults:root,%wheel  env_keep+=EDITOR
      '';
      extraRules = [
        {
          commands = builtins.concatLists (
            map
              (
                args: [
                  { command = "/bin/systemctl " + args; options = [ "NOPASSWD" ]; }
                  { command = "/run/current-system/sw/bin/systemctl " + args; options = [ "NOPASSWD" ]; }
                ]
              ) [
              "suspend"
              "suspend-then-hibernate"
              "hibernate"
              "restart display-manager"
              "restart nixos-upgrade"
              "reboot"
            ]
          );
          groups = [ "wheel" ];
        }
        {
          commands = builtins.concatLists (
            map
              (
                args: [
                  { command = args; options = [ "NOPASSWD" ]; }
                ]
              ) [
              "/run/current-system/sw/bin/shutdown -r"
              "/run/current-system/sw/bin/reboot"
            ]
          );
          groups = [ "wheel" ];
        }
      ];
    };
  };
}

# vim: set ts=2 sw=2 :
