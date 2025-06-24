{ config, lib, pkgs, ... }:

with config.nixpkgs;
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in
rec {
  imports = [ ./xcompose.nix ];

  console.useXkbConfig = true;

  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
    };
    #inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ m17n ];
    extraLocaleSettings = {
      LC_TIME = "cs_CZ.UTF-8";
    };
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "cs_CZ.UTF-8/UTF-8"
      "cs_CZ/ISO-8859-2"
      "ru_RU.UTF-8/UTF-8"
      "ru_RU/ISO-8859-5"
      "de_DE.UTF-8/UTF-8"
      "de_DE/ISO-8859-1"
      "it_IT.UTF-8/UTF-8"
      "it_IT/ISO-8859-1"
    ];
  };

  services = {
    ddccontrol.enable = true;
    libinput = {
      enable = true;
      touchpad = {
        clickMethod = "none";
        naturalScrolling = true;
        tapping = false;
      };
    };

    xserver = {
      enable = true;

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
        wayland = lib.mkDefault true;
      };
    };

    # gnome related
    gnome = {
      at-spi2-core.enable = true;
      gnome-browser-connector.enable = true;
      core-os-services.enable = true;
      core-shell.enable = true;
      core-apps.enable = true;
      evolution-data-server.enable = true;
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
      gnome-remote-desktop.enable = true;
      gnome-settings-daemon.enable = true;
      gnome-user-share.enable = true;
      sushi.enable = true;
      #tracker-miners.enable = true;
      #tracker.enable = true;
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

      # Marog 14 - maps presentation key to menu (compose key)
      evdev:input:b0001v0B05p19B6*
       KEYBOARD_KEY_70013=menu
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

    udev.packages = [ pkgs.zsa-udev-rules ];
  };

  fonts = {
    enableDefaultPackages = true;
    fontDir = {
      enable = true;
    };
    packages = with pkgs; lib.mkAfter [
      fira-code-symbols
      fira-code
      google-fonts
      inconsolata-lgc
      liberation_ttf
      libre-caslon
      navilu-font

      #nerd-fonts.0xproto
      #nerd-fonts.3270
      nerd-fonts.adwaita-mono
      #nerd-fonts.agave
      #nerd-fonts.anonymouspro
      #nerd-fonts.arimo
      #nerd-fonts.atkinsonhyperlegiblemono
      #nerd-fonts.aurulentsansmono
      #nerd-fonts.bigblueterminal
      #nerd-fonts.bitstreamverasansmono
      #nerd-fonts.cascadia-mono
      #      nerd-fonts.codenewroman
      nerd-fonts.comic-shanns-mono
      #      nerd-fonts.commit-mono
      #      nerd-fonts.cousine
      #      nerd-fonts.d2coding
      #      nerd-fonts.daddytime-mono
      nerd-fonts.dejavu-sans-mono
      #      nerd-fonts.departure-mono
      nerd-fonts.droid-sans-mono
      #      nerd-fonts.envycoder
      #      nerd-fonts.fantasquesans-mono
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      #      nerd-fonts.geist-mono
      #      nerd-fonts.gohu
      nerd-fonts.go-mono
      #      nerd-fonts.hack
      #      nerd-fonts.hasklig
      #      nerd-fonts.heavydata
      #      nerd-fonts.hermit
      #      nerd-fonts.ia-writer
      #      nerd-fonts.ibmplex-mono
      nerd-fonts.inconsolata
      nerd-fonts.inconsolata-go
      #      nerd-fonts.inconsolatalgc
      #      nerd-fonts.intelone-mono
      #      nerd-fonts.iosevka
      #      nerd-fonts.iosevkaterm
      #      nerd-fonts.iosevkatermslab
      #      nerd-fonts.jetbrains-mono
      #      nerd-fonts.lekton
      nerd-fonts.liberation
      #      nerd-fonts.lilex
      #      nerd-fonts.martian-mono
      #      nerd-fonts.meslo
      #      nerd-fonts.monaspace
      #      nerd-fonts.monofur
      #      nerd-fonts.monoid
      #      nerd-fonts.mononoki
      #      nerd-fonts.mplus
      nerd-fonts.symbols-only
      #      nerd-fonts.noto
      #      nerd-fonts.opendyslexic
      #      nerd-fonts.overpass
      nerd-fonts.profont
      #      nerd-fonts.proggyclean
      #      nerd-fonts.recursive
      #      nerd-fonts.roboto-mono
      #      nerd-fonts.sharetech-mono
      # nerd-fonts.sourcecodepro
      nerd-fonts.space-mono
      # nerd-fonts.terminus
      nerd-fonts.tinos
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      #      nerd-fonts.victor-mono
      nerd-fonts.zed-mono

      pecita
      powerline-fonts
      profont
      source-sans-pro
      source-serif-pro
      # terminus-nerdfont
      nerd-fonts.terminess-ttf
      terminus_font
      terminus_font_ttf
      ubuntu_font_family
    ];
  };

  programs = {
    gnome-terminal.enable = true;
    #gnome-documents.enable = true;
    gnome-disks.enable = true;
    file-roller.enable = true;
    evince.enable = true;
    dconf.enable = true;
    xwayland.enable = lib.mkDefault true;
    firefox = {
      languagePacks = [ "cs" "en-US" ];
      nativeMessagingHosts = {
        tridactyl = true;
        browserpass = true;
        packages = [
          gnome-browser-connector
        ];
      };
    };
  };

  environment = {
    variables = {
      ECORE_IMF_MODULE = "fcitx";
      QT_QPA_PLATFORM = "wayland";
      ANKI_WAYLAND = "1";
      GOLDENDICT_FORCE_WAYLAND = "1";
    };

    systemPackages = with pkgs; [
      # X utilities **************************
      dconf-editor
      barrier
      dex
      ddccontrol
      dunst
      evtest
      feh
      glxinfo
      gnome-session
      graphicsmagick
      libnotify
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
      wl-clipboard

      # GUI **********************************
      unstable.anki
      #unstable.anki-bin
      #blueman
      brasero
      calibre
      d-spy
      #fontmatrix
      gcolor3
      gparted
      goldendict-ng
      gucharmap
      flatpak
      # k3b
      kdePackages.kcharselect
      kdePackages.kwin
      #megasync
      qtpass
      obsidian
      poedit
      protonmail-bridge
      rclone
      tigervnc
      unetbootin

      gnome-shell-extensions
      # gnomeExtensions.gtile
      gnomeExtensions.vitals
      gnomeExtensions.paperwm
      # gnomeExtensions.pop-shell
      gnomeExtensions.unite
      gnomeExtensions.kimpanel
      #gnomeExtensions.jiggle

      # network
      networkmanagerapplet
      wireshark
      protonvpn-gui

      # guitar
      #perlPackages.AppMusicChordPro
      musescore
      tuxguitar

      # office
      birdtray # tray indicator for thunderbird
      evince
      #kdeApplications.okular
      libreoffice
      #libreoffice-fresh
      libreoffice-fresh-unwrapped
      notepadqq
      onlyoffice-bin
      pdf-quench
      pdfarranger
      pdftk
      thunderbird

      #webcam
      cheese
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
      picom
      adwaita-qt
      adwaita-qt6
      adwaita-icon-theme
      gnome-tweaks
      libsForQt5.breeze-gtk
      gnomeExtensions.just-perfection
      gnomeExtensions.user-themes
      gnomeExtensions.user-themes-x
      gnome-themes-extra
      gnome-software
      gnomeExtensions.pano
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
      alacritty
      anonymousPro
      cantarell-fonts
      kitty
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
      kdePackages.gwenview
      inkscape-with-extensions
      kdePackages.kolourpaint
      krita
      kdePackages.skanlite
      #yed

      # video
      ffmpeg-full
      handbrake

      # video players
      mpv
      smplayer
      vlc

      # web browsers
      microsoft-edge
      chromium
      firefox
      firefox-esr
      # need to update url
      #tor-browser-bundle-bin

      # chat
      #skypeforlinux
      slack
      #signal-desktop
      tdesktop
      zoom-us
    ];
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita";
  };

  environment.sessionVariables = rec {
    NIXOS_OZONE_WL = "1";
  };
}
# ex: set et ts=2 sw=2 :
