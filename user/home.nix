{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

  # TODO: don't assume we run on NixOS
  systemConfig = (import <nixpkgs/nixos> { system = config.nixpkgs.system; }).config;
  systemPackages = (import <nixpkgs/nixos> { }).pkgs;
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
  home.stateVersion =
    if systemConfig.networking.hostName == "marog14" then
      "23.05"
    else
      "22.11";

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

  home.packages = with pkgs; [
    python3Packages.argcomplete
    python3Packages.python-gitlab

    (writeShellScriptBin "_gitlab-get-token-sissource" ''
      #!/usr/bin/env bash
      exec ${pkgs.gopass}/bin/gopass show ethpriv/gitlab/sissource/mminar
    '')
  ] ++ (lib.optionals systemConfig.profile.work.enable [
    (writeShellScriptBin "sseth" (
      builtins.readFile ~/wsp/nixos/secrets/ethz/scripts/eth-ssh))
  ]) ++ (lib.optionals (systemConfig.profile.server.enable) [
    (writeShellScriptBin "michowp" (
      builtins.readFile ./scripts/michowp.sh))
  ]) ++ (lib.optionals (!systemConfig.profile.server.enable) [
    (import ./chrome-wrappers.nix { homeDir = home.homeDirectory; })
  ]) ++ (lib.optionals (!systemConfig.profile.server.enable) [
    (import ./w3.nix { })
  ]);

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    browserpass = {
      enable = true;
      browsers = [ "chrome" "chromium" "firefox" ];
    };

    fzf = {
      enable = true;
      tmux.enableShellIntegration = true;
    };

    oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
    } // (
      if systemConfig.networking.hostName == "michowps" then
        { useTheme = "illusi0n"; }
      else if systemConfig.networking.hostName == "marog14" then
        { useTheme = "blue-owl"; }
      else
        { settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./home/oh-my-posh-conf.json)); }
    );

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
        {
          plugin = power-theme;
          extraConfig =
            let
              theme =
                if systemConfig.networking.hostName == "michowps" then
                  "snow"
                else if systemConfig.networking.hostName == "marog14" then
                  "sky"
                else
                  "gold";
            in
            "set -g @tmux_power_theme '${theme}'";
        }
        copycat
        logging
        open
        sensible
        yank
        cpu
      ];
      extraConfig = ''
        set -g set-titles on
        set-option -g mouse on

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

          ''
            eval "$(${pkgs.python3Packages.argcomplete}/bin/register-python-argcomplete gitlab)"
          ''
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

  home = {
    sessionVariables = lib.mkIf systemConfig.profile.work.enable {
      VAULT_ADDR = lib.removeSuffix "\n" (
        lib.readFile ~/wsp/nixos/secrets/ethz/env/VAULT_ADDR);
      VAULT_USERNAME = "adm-mminar";
      BROWSER = "chrome-launcher";
    };
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

  home.file.".python-gitlab.cfg" = lib.mkIf systemConfig.profile.work.enable {
    # TODO: generate based on profile settings
    text = lib.readFile ~/wsp/nixos/secrets/home/python-gitlab.cfg;
  };
}
