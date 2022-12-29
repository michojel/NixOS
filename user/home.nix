{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

  # TODO: don't assume we run on NixOS
  systemConfig = (import <nixpkgs/nixos> { system = config.nixpkgs.system; }).config;
in
rec {
  imports = [
    ./home/neovim.nix
    ./home/git.nix
    ./home/gpg.nix
    ./home/dconf.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = systemConfig.local.username;
  home.homeDirectory = "/home/${home.username}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.shellAliases = {
    mux = "tmuxinator";
    k = "kubectl";
    knm = "kubectl config set-context --current --namespace";
    #    imgclipb = lib.concatStringsSep " " [
    #      ''xclip -selection clipboard''
    #      ''-t image/png -o > ~/Pictures/Screenshots/"$(date +%Y-%m-%d_%T).png"''
    #    ];
    cGR = ''cd "$(git root)"'';
  };

  home.packages = [ ] ++ (pkgs.lib.optionals systemConfig.profile.work.enable [
    (pkgs.writeShellScriptBin "sseth" (
      builtins.readFile ~/wsp/nixos/secrets/ethz/scripts/eth-ssh))
  ]) ++ (pkgs.lib.optionals (!systemConfig.profile.server.enable) [
    (import ./chrome-wrappers.nix { homeDir = home.homeDirectory; })
  ]) ++ (pkgs.lib.optionals (!systemConfig.profile.server.enable) [
    (import ./w3.nix { })
  ]);

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      tmux.enableShellIntegration = true;
    };

    oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      #useTheme = "mojada";
      settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./home/oh-my-posh-conf.json));
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
      # not yet in 22.05
      # enableCompletion = true;
      enableVteIntegration = true;
      initExtra =
        let autoCompleteAlias = a: "complete -F _complete_alias " + a;
        in
        lib.mkAfter (lib.concatStringsSep "\n" [
          (lib.readFile ./home/bash-init-extra.sh)
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

  home.file.".config/user-dirs.dirs" = {
    text = lib.readFile ./home/user-dirs.dirs;
  };

  home.file.".ssh/ethz/config_base" = lib.mkIf systemConfig.profile.work.enable {
    text = lib.readFile ~/wsp/nixos/secrets/ethz/ssh/config_base;
  };
  home.file.".ssh/ethz/config_defaults" = lib.mkIf systemConfig.profile.work.enable {
    text = lib.readFile ~/wsp/nixos/secrets/ethz/ssh/config_defaults;
  };

  home.file.".ssh/ethz/config_sseth" = lib.mkIf systemConfig.profile.work.enable {
    text = ''
      Include ~/.ssh/ethz/config_base
      Include ~/.ssh/ethz/config_defaults

      # ex: et ts=4 sw=4 ft=sshconfig :
    '';
  };

  home.file.".ldaprc" = lib.mkIf systemConfig.profile.work.enable {
    text = lib.readFile ~/wsp/nixos/secrets/ethz/rc/ldap.conf;
  };

}
