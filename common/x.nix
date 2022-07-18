{ config, lib, pkgs, ... }:

with config.nixpkgs;
let
  firefoxConfig = {
    enableGnomeExtensions = true;
    gssSupport = true;
    enableTridactylNative = true;
  };

  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
      firefox = firefoxConfig;
    };
  };
in
rec {
  imports = [ ./xcompose.nix ];

  console.useXkbConfig = true;

  i18n = {
    inputMethod.enabled = "fcitx5";
    #inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ m17n ];
    extraLocaleSettings = {
      LC_TIME = "cs_CZ.UTF-8";
    };
  };

  services = {
    ddccontrol.enable = true;
    xserver = {
      enable = true;

      layout = "us,ru";
      xkbVariant = "cz_sk_de,";
      xkbOptions = "terminate:ctrl_alt_bksp,grp_led:scroll,lv3:ralt_switch_multikey,nbsp:level3,compose:menu";

      libinput = {
        enable = true;
        touchpad = {
          clickMethod = "none";
          naturalScrolling = true;
          tapping = false;
        };
      };

      wacom.enable = true;

      config =
        ''
          Section           "InputClass"
            Identifier      "Logitech Trackball"
            Driver          "evdev"
            MatchProduct    "Trackball"
            MatchIsPointer  "on"
            MatchDevicePath "/dev/input/event*"
            Option          "ButtonMapping"      "1 8 3 4 5 6 7 2 9"
            Option          "EmulateWheel"       "True"
            Option          "EmulateWheelButton" "9"
            Option          "XAxisMapping"       "6 7"
          EndSection
        '';

      # create a symlink target /etc/X11/xorg.conf
      exportConfiguration = true;

      desktopManager = {
        gnome.enable = true;
      };

      displayManager.gdm = {
        enable = true;
        wayland = false;
      };
    };

    # gnome related
    gnome = {
      at-spi2-core.enable = true;
      chrome-gnome-shell.enable = true;
      core-os-services.enable = true;
      core-shell.enable = true;
      core-utilities.enable = true;
      evolution-data-server.enable = true;
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
      gnome-remote-desktop.enable = true;
      gnome-settings-daemon.enable = true;
      gnome-user-share.enable = true;
      sushi.enable = true;
      tracker.enable = true;
      tracker-miners.enable = true;
    };

    # righthand side can be found at https://github.com/westonal/android-ndk/blob/master/sysroot/usr/include/linux/input-event-codes.h
    # lefthandside can be determined with sudo evtest /dev/input/eventX
    # evdev:input:* line with lsusb
    # more at https://wiki.archlinux.org/index.php/Map_scancodes_to_keycodes
    udev.extraHwdb = ''
      # Razer Naga Trinity buttons 1, 2, ..., 7
      evdev:input:b0003v1532p0067*
       KEYBOARD_KEY_7001e=leftctrl
       KEYBOARD_KEY_7001f=leftshift
       KEYBOARD_KEY_70020=leftalt
       KEYBOARD_KEY_70021=leftmeta
       KEYBOARD_KEY_70022=esc
       KEYBOARD_KEY_70023=back
       KEYBOARD_KEY_70024=forward
    '';

    # Razer Naga Trinity
    # # 12 button layout
    #evdev:input:b0003v1532p0067*
    #KEYBOARD_KEY_7001e=leftctrl
    #KEYBOARD_KEY_7001f=leftshift
    #KEYBOARD_KEY_70020=leftalt
    #KEYBOARD_KEY_70021=leftmeta
    #KEYBOARD_KEY_70022=rightmeta
    #KEYBOARD_KEY_70023=compose
    #KEYBOARD_KEY_70024=space
    #KEYBOARD_KEY_70025=backspace
    #KEYBOARD_KEY_70026=esc
    #KEYBOARD_KEY_70027=back
    #KEYBOARD_KEY_7002d=forward
    #KEYBOARD_KEY_7002e=context_menu

    udev.packages = [ unstable.zsa-udev-rules ];
  };

  fonts = {
    enableDefaultFonts = true;
    fontDir = {
      enable = true;
    };
    fonts = with pkgs; lib.mkAfter [
      fira-code-symbols
      fira-code
      #google-fonts
      inconsolata-nerdfont
      inconsolata-lgc
      liberation_ttf
      nerdfonts
      powerline-fonts
      profont
      source-sans-pro
      source-serif-pro
      terminus-nerdfont
      terminus_font
      terminus_font_ttf
      ubuntu_font_family
    ];
  };

  qt5.platformTheme = "gnome";

  programs = {
    gnome-terminal.enable = true;
    #gnome-documents.enable = true;
    gnome-disks.enable = true;
    file-roller.enable = true;
    evince.enable = true;
    dconf.enable = true;
  };

  environment = {
    variables = {
      ECORE_IMF_MODULE = "fcitx";
    };

    systemPackages = with pkgs; [
      # X utilities **************************
      alarm-clock-applet
      gnome3.dconf-editor
      devilspie2
      dex
      ddccontrol
      dunst
      evtest
      feh
      glxinfo
      gnome3.gnome-session
      graphicsmagick
      libnotify
      qt512.qttools
      scrot
      #teamviewer
      wmctrl
      xorg.xbacklight
      xorg.xclock
      xclip
      xorg.xeyes
      xorg.xev
      xorg.setxkbmap
      xorg.xhost
      xorg.xkbcomp
      xorg.xmodmap
      xfontsel
      xorg.xkill
      xorg.xdpyinfo
      xsel

      # GUI **********************************
      #anki
      anki-bin
      #blueman
      brasero
      calibre
      dfeet
      fontmatrix
      gcolor2
      goldendict
      gparted
      gnome.gnome-shell-extensions
      gucharmap
      flatpak
      k3b
      kcharselect
      kwin
      #megasync
      pinentry_gnome
      qtpass
      protonmail-bridge
      rclone
      tigervnc
      unetbootin
      gnomeExtensions.gtile
      gnomeExtensions.timepp
      gnomeExtensions.vitals
      #gnomeExtensions.jiggle

      # network
      networkmanagerapplet
      wireshark

      # guitar
      # broken qtwebkit on 20.09 stable
      musescore
      tuxguitar

      # office
      evince
      #kdeApplications.okular
      #libreoffice-fresh
      libreoffice-fresh-unwrapped
      notepadqq
      onlyoffice-bin
      pdf-quench
      pdfarranger
      pdftk
      thunderbird
      xournal

      # editors
      gnvim
      neovim-qt

      #webcam
      gnome3.cheese
      fswebcam
      #wxcam

      # look
      adapta-gtk-theme
      adapta-kde-theme
      amber-theme
      arc-icon-theme
      arc-kde-theme
      arc-theme
      capitaine-cursors
      clearlooks-phenix
      compton
      gnome3.adwaita-icon-theme
      gnome3.gnome-tweaks
      libsForQt5.breeze-gtk
      gnomeExtensions.adwaita-theme-switcher
      gnomeExtensions.just-perfection
      gnomeExtensions.user-themes
      gnomeExtensions.user-themes-x
      gnome.gnome-themes-extra
      greybird
      hicolor-icon-theme
      materia-theme
      numix-cursor-theme
      numix-gtk-theme
      numix-icon-theme
      numix-icon-theme-circle
      numix-icon-theme-square
      plano-theme
      profont
      stilo-themes
      theme-obsidian2
      theme-vertex
      xorg.xcursorthemes
      yaru-theme
      zuki-themes

      # terminal emulators
      anonymousPro
      cantarell-fonts
      roxterm
      terminator
      enlightenment.terminology
      tilix

      # peripherals
      wally-cli

      # graphics
      dia
      digikam
      gimp
      gwenview
      inkscape-with-extensions
      kolourpaint
      krita
      skanlite
      yed

      # video
      ffmpeg-full

      # video players
      mpv
      smplayer
      vlc

      # web browsers
      chromium
      firefox
      firefox-esr
      tridactyl-native
      # need to update url
      #tor-browser-bundle-bin

      # chat
      #skypeforlinux
      #zoom-us
      tdesktop
    ];
  };

  nixpkgs.config = {
    firefox = firefoxConfig;
    # enable qtwebkit and its dependencies
    # https://github.com/NixOS/nixpkgs/issues/53079
    allowBroken = true;
  };

  #hardware.keyboard.zsa.enable = true;

  systemd.user.services = {
    devilspie2 = {
      after = [ "graphical.target" "gvfs-daemon.service" "gnome-session-x11.target" ];
      #requires = [ "graphical.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Restart = "always";
      };
      script = ''
        #!${pkgs.bash}/bin/bash

        set -euo pipefail
        IFS=$'\n\t'

        if [[ -z "''${DISPLAY:-}" ]]; then
          DISPLAY="${if config.services.xserver.display == null then ":0" else config.services.xserver.display}"
          printf 'Defaulting DISPLAY to %s\n' "$DISPLAY" >&2
        fi
        if [[ -z "''${XAUTHORITY:-}" ]]; then
          if [[ -e "/run/user/$UID/gdm/Xauthority" ]]; then
            XAUTHORITY="/run/user/$UID/gdm/Xauthority"
          else
            XAUTHORITY="''${HOME}/.Xauthority"
          fi
          printf 'Defaulting XAUTHORITY to %s\n' "$XAUTHORITY" >&2
        fi
        export DISPLAY XAUTHORITY
        exec "${pkgs.devilspie2}/bin/devilspie2";
      '';
      description = "Devil's Pie for window management under X11";
    };
  };

}
# ex: set et ts=2 sw=2 :
