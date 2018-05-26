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
      bind
      file
      fzf
      git

      # TODO: reduce dependencies to make it X free
      gnupg
      gnupg1compat

      htop
      jq
      mc
      neovim
      nix-repl
      silver-searcher
      tree
      wget
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
