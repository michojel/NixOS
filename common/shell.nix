{ config, lib, pkgs, ... }:

{
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
    shells = [pkgs.bashInteractive];
    variables = {
      EDITOR = lib.mkOverride 900 "nvim";
    };

    # essential cli tools
    systemPackages = with pkgs; [
      ack
      ag
      anki
      bc
      bind
      cryptsetup
      curl
      duplicity
      fdupes
      file

      fzf
      vimPlugins.fzfWrapper
      vimPlugins.fzf-vim

      gist
      git
      gitAndTools.git-annex
      gitAndTools.hub

      # TODO: reduce dependencies to make it X free
      gnupg
      #gnupg1compat

      gptfdisk
      htop
      iftop
      iotop
      jq
      libxml2
      mc
      megatools
      ncdu
      neovim
      nixUnstable
      ntp
      parallel
      pciutils
      pinentry
      pinentry_ncurses
      procps
      pwgen
      sshfs
      silver-searcher
      tmux
      tmuxinator
      tree
      vim
      unzip
      wget
      yq
      zfstools
    ];
  };

  programs = {
    bash = {
      enableCompletion = true;
      interactiveShellInit =
        ''
          if command -v fzf-share >/dev/null; then
            source "$(fzf-share)/key-bindings.bash"
          fi
        '';
    };
    command-not-found.enable = true;
    gnupg.agent = { enable = true; enableSSHSupport = true; };

    tmux = {
      enable              = true;
      clock24             = true;
      historyLimit        = 10000;
      keyMode             = "vi";
      newSession          = true;
    };
  };

  security = {
    sudo.extraConfig = ''
        Defaults:root,%wheel  !tty_tickets
        Defaults:root,%wheel  timestamp_timeout = 10
        Defaults:root,%wheel  env_keep+=EDITOR
      '';
   };
}

# vim: set ts=2 sw=2 :
