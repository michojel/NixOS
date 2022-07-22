{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

  nvim-nu = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-nu";
    version = "2022-02-17";
    #version = "2021-07-10";
    src = pkgs.fetchFromGitHub {
      owner = "LhKipp";
      repo = "nvim-nu";
      rev = "3ef01939989f4d45520873fdac23a2cd7c9c226b";
      sha256 = "0cq9a93qqxa6kc318g7d8d5rg6rsmavpcddw3vx0sf2r6j7gm8vj";
      #rev = "8729cbfc0d299c94fce0add2c5cfc00b043d6fe1";
      #sha256 = "1q7m5lm4b1jpmw8gzsms7xynkkzngk7jnfdk83vsgszn7nswbyyh";
    };
    meta.homepage = "https://github.com/LhKipp/nvim-nu";
  };
in
rec {
  imports = [
    ./dconf.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username =
    if lib.pathExists /home/miminar then
      "miminar"
    else "michojel";
  home.homeDirectory = "/home/${home.username}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.shellAliases = {
    mux = "tmuxinator";
    k = "kubectl";
    knm = "kubectl config set-context --current --namespace";
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      userName = "Michal Minář";
      userEmail = "mm@michojel.cz";
      delta.enable = true;
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
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };

    fzf = {
      enable = true;
      tmux.enableShellIntegration = true;
    };

    starship = {
      enable = true;
      enableBashIntegration = true;
      package = unstable.starship;
      settings = {
        time = {
          disabled = false;
        };
        nix_shell = {
          disabled = false;
        };
        #        sudo = {
        #          disabled = false;
        #        };
        character = {
          vicmd_symbol = "[V](bold green) ";
        };
        status = {
          disabled = false;
        };
        shell = {
          disabled = false;
        };
        shlvl = {
          disabled = false;
        };
        hostname = {
          disabled = false;
        };
        username = {
          disabled = false;
        };
      };
    };

    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      terminal = "screen-256color";
      tmuxinator.enable = true;
      #shell = "${unstable.nushell}/bin/nu";
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        better-mouse-mode
        power-theme
        copycat
        logging
        open
        sensible
        yank
      ];
      extraConfig = ''
        set -g @tmux_power_theme 'gold'
        set-option -g mouse on

        set -g set-titles on

        bind Tab last-window
      '';
    };

    readline = {
      enable = true;
      bindings = {
        # Map (UTF-8) non-breaking space to regular space, in case the user
        # accidentally types Option-Space or Shift-Space when they meant Space.
        "\\xC2\\xA0" = ''" "'';
        "\\eo" = ''"\\C-p\\C-a\\ef "'';
        # Make Meta+S cycle through the list of completions
        "\\em" = "menu-complete";
        # autocomplete by pressing Tab
        "Tab" = "complete";
      };

      variables = {
        editing-mode = "vi";
        visible-stats = true;
        mark-modified-lines = true;
        mark-directories = true;
        page-completions = true;
        skip-completed-text = true;
        match-hidden-files = false;
        show-all-if-ambiguous = true;
        # to make <delete> key work in Suckless Terminal
        enable-keypad = true;
        show-mode-in-prompt = true;
      };

      extraConfig = ''
        $if mode=emacs
            "\ei": overwrite-mode
            "\ew": kill-region
            #"\C-w": kill-region
            #"\ew": copy-region-as-kill
            "\e ": set-mark
        $endif
        $if mode=vi
          set vi-ins-mode-string \1\e[6 q\2
          set vi-cmd-mode-string \1\e[2 q\2
          "\e.": yank-last-arg
        $endif

        # disable beep
        set bell-style none
      '';
    };

    bash = {
      enable = true;
      enableVteIntegration = true;
      initExtra =
        let autoCompleteAlias = a: "complete -F _complete_alias " + a;
        in
        lib.mkAfter (lib.concatStringsSep "\n" [
          (lib.readFile ./bash-init-extra.sh)
          ''
            source ${pkgs.bash-completion}/share/bash-completion/bash_completion
            source ${pkgs.complete-alias}/bin/complete_alias
          ''
          # auto-complete all aliases
          (lib.concatStringsSep "\n" (lib.mapAttrsToList
            (alias: v: autoCompleteAlias alias)
            home.shellAliases))
          (autoCompleteAlias "vimdiff")
        ]);
      historyControl = [ "erasedups" "ignorespace" ];
      shellAliases = {
        "hR" = "history -r";
      };
    };

    bat.enable = true;

  };

}
