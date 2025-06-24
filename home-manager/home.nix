{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

  # TODO: don't assume we run on NixOS
  systemConfig = (import <nixpkgs/nixos> { system = config.nixpkgs.system; }).config;
  systemPackages = (import <nixos> { }).pkgs;
in
rec {
  imports = [
    ./modules/neovim.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/dconf.nix
    ./modules/alacritty.nix
    ./modules/protonmail-bridge.nix
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
  home.stateVersion = "25.05";

  #  home.activation = {
  #    updateFontCache = ''
  #      echo "Updating font cache..."
  #      ${systemPackages.fontconfig}/bin/fc-cache --force #--error-on-no-fonts
  #    '';
  #  };

  fonts.fontconfig = {
    enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager = {
    enable = true;
  };
  # home-manager.useUserPackages = true;
  ## TODO: enable
  # home-manager.useGlobalPkgs = true;

  home.shellAliases = {
    mux = "tmuxinator";
    tmL = "tmuxp load";
    k = "kubectl";
    knm = "kubectl config set-context --current --namespace";
    #    imgclipb = lib.concatStringsSep " " [
    #      ''xclip -selection clipboard''
    #      ''-t image/png -o > ~/Pictures/Screenshots/"$(date +%Y-%m-%d_%T).png"''
    #    ];
    cGR = ''cd "$(git root)"'';
    k3tl = ''sudo k3s kubectl'';
  };

  qt = {
    enable = !systemConfig.profile.server.enable;
    platformTheme = {
      name = "adwaita";
    };
    style = {
      name = "adwaita";
    };
  };

  home.packages = with pkgs; [
    python3Packages.argcomplete
    python3Packages.python-gitlab
    (writeShellScriptBin "_gitlab-get-token-sissource" ''
      #!/usr/bin/env bash
      exec ${pkgs.gopass}/bin/gopass show ethpriv/gitlab/sissource/mminar
    '')

    # TODO add dependencis to PATH
    (writeShellScriptBin "glabcleanup" (builtins.readFile ./scripts/glabcleanup))

  ] ++ (lib.optionals systemConfig.profile.work.enable [
    (writeShellScriptBin "sseth" (
      builtins.readFile ~/wsp/nixos/secrets/ethz/scripts/eth-ssh))
    # (writeShellScriptBin "kuberefreshconfigs" (
    # builtins.readFile ~/wsp/nixos/secrets/ethz/scripts/kuberefreshconfigs))
    #(writeShellScriptBin "sjobsfinish" (
    #builtins.readFile ~/wsp/nixos/secrets/ethz/scripts/sjobsfinish))
  ]) ++ (lib.optionals (systemConfig.profile.server.enable) [
    (writeShellScriptBin "michowp" (
      builtins.readFile ./scripts/michowp.sh))
  ]) ++ (lib.optionals (!systemConfig.profile.server.enable) [
    google-chrome
    (import ./pkgs/chrome-wrappers.nix {
      homeDir = home.homeDirectory;
      disableGPU = (systemConfig.networking.hostName != "marog14");
    })
    (import ./pkgs/w3.nix { })
    gnvim
  ]);

  programs = {
    chromium = {
      enable = !systemConfig.profile.server.enable;
      commandLineArgs = (if (systemConfig.networking.hostName != "marog14") then
        [
          "--add-flags"
          "--disable-gpu"
        ] else [ ]) ++ [
        "--ozone-platform=wayland"
        "--ozone-platform-hint=auto"
        "--gtk-version=4"
      ];
      extensions = [
        # Quick Tabs https://chrome.google.com/webstore/detail/quick-tabs/jnjfeinjfmenlddahdjdmgpbokiacbbb
        { id = "jnjfeinjfmenlddahdjdmgpbokiacbbb"; }
        # Proxy SwitchyOmega https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif
        { id = "padekgcemlokbadohgkifijomclgjgif"; }
        # Surfingkeys https://chrome.google.com/webstore/detail/surfingkeys/gfbliohnnapiefjpjlpjnehglfpaknnc
        { id = "gfbliohnnapiefjpjlpjnehglfpaknnc"; }
        # Markdown Preview Plus https://chrome.google.com/webstore/detail/markdown-preview-plus/febilkbfcbhebfnokafefeacimjdckgl
        { id = "febilkbfcbhebfnokafefeacimjdckgl"; }
        # Gmail
        { id = "fmgjjmmmlfnkbppncabfkddbjimcfncm"; }
        # Browserpass https://chrome.google.com/webstore/detail/browserpass/naepdomgkenhinolocfifgehidddafch
        { id = "naepdomgkenhinolocfifgehidddafch"; }
        # Google Docs Offline https://chrome.google.com/webstore/detail/google-docs-offline/ghbmnnjooekpmoecnnnilnnbdlolhkhi
        { id = "ghbmnnjooekpmoecnnnilnnbdlolhkhi"; }
        # Office editing for Docs https://chrome.google.com/webstore/detail/office-editing-for-docs-s/gbkeegbaiigmenfmjfclcdgdpimamgkj
        { id = "gbkeegbaiigmenfmjfclcdgdpimamgkj"; }
      ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    browserpass = {
      enable = !systemConfig.profile.server.enable;
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
        { settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./modules/oh-my-posh-conf.json)); }
    );

    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      terminal = "screen-256color";
      tmuxinator.enable = true;
      tmuxp.enable = true;
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

          set keymap vi-command
          "k": history-search-backward
          "j": history-search-forward

          set keymap vi-insert
          "\C-A": beginning-of-line
          "\C-B": backward-char
          "\C-D": delete-char
          "\C-E": end-of-line
          "\C-F": forward-char
          "\C-K": kill-line
          "\C-L": clear-screen
          "\C-N": next-history
          "\C-P": previous-history
          "\C-O": operate-and-get-next

          # Enable Readline not waiting for additional input when a key is pressed.
          # Needed for the mappings below.
          set keyseq-timeout 0

          # `yank-last-arg` does not work exactly as in emacs mode
          "\e\177": backward-kill-word
          "\e0": digit-argument
          "\e1": digit-argument
          "\e2": digit-argument
          "\e3": digit-argument
          "\e4": digit-argument
          "\e5": digit-argument
          "\e6": digit-argument
          "\e7": digit-argument
          "\e8": digit-argument
          "\e9": digit-argument
          "\eb": backward-word
          "\ec": capitalize-word
          "\ed": kill-word
          "\ef": forward-word
          "\el": downcase-word
          "\en": non-incremental-forward-search-history
          "\ep": non-incremental-reverse-search-history
          "\et": transpose-words
          "\eu": upcase-word
          "\ey": yank-pop

          # some other useful mappings

          "\e/": complete-filename
          "\ek": kill-whole-line
          "\eo": "\C-v\C-j"
          # quickly switch to "normal" mode
          "\C-[": vi-movement-mode
          # perserve the currently editing line so that we can 
          # do something else before restoring it.
          "\eg": insert-comment
          "\er": "\C-R#\C-A\C-D\C-E"
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
          ''
            for p in .krew/bin .local/bin .cabal/bin bin wsp/go/binaries; do
                p="$HOME/$p"
                if [[ -d "$p" ]] && echo "$PATH" | grep -qvF "$p"; then
                    pth="$p:''${pth:-}"
                fi
            done
            export PATH="''${pth:-}$PATH"
            unset p pth
          ''
          (lib.readFile ./modules/bash-init-extra.sh)
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
    text = lib.readFile ./modules/user-dirs.dirs;
  };

  home = {
    sessionVariables = lib.mkIf systemConfig.profile.work.enable {
      VAULT_ADDR = lib.removeSuffix "\n" (
        lib.readFile ~/wsp/nixos/secrets/ethz/env/VAULT_ADDR);
      VAULT_USERNAME = "adm-mminar";
      BROWSER = "chrome-launcher";
    };
  };

  home.file.".ssh/ethz/config_base" = lib.mkIf
    systemConfig.profile.work.enable
    {
      text = lib.readFile ~/wsp/nixos/secrets/ethz/ssh/config_base;
    };
  home.file.".ssh/ethz/config_defaults" = lib.mkIf
    systemConfig.profile.work.enable
    {
      text = lib.readFile ~/wsp/nixos/secrets/ethz/ssh/config_defaults;
    };

  home.file.".ssh/ethz/config_sseth" = lib.mkIf
    systemConfig.profile.work.enable
    {
      text = ''
        Include ~/.ssh/ethz/config_base
        Include ~/.ssh/ethz/config_defaults

        # ex: et ts=4 sw=4 ft=sshconfig :
      '';
    };

  home.file.".ldaprc" = lib.mkIf
    systemConfig.profile.work.enable
    {
      text = lib.readFile ~/wsp/nixos/secrets/ethz/rc/ldap.conf;
    };

  home.file.".python-gitlab.cfg" = lib.mkIf
    systemConfig.profile.work.enable
    {
      # TODO: generate based on profile settings
      text = lib.readFile ~/wsp/nixos/secrets/home/python-gitlab.cfg;
    };

  nixpkgs.overlays = lib.optionals
    (!systemConfig.profile.server.enable)
    [
      (self: super: {
        gnvim = super.gnvim.override {
          neovim = config.programs.neovim.finalPackage;
        };
      }
      )
    ];

  services.protonmail-bridge = {
    enable = true;
  };
}
