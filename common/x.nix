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
        wayland = lib.mkDefault true;
      };
    };

    # gnome related
    gnome = {
      at-spi2-core.enable = true;
      gnome-browser-connector.enable = true;
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
    enableDefaultFonts = true;
    fontDir = {
      enable = true;
    };
    fonts = with pkgs; lib.mkAfter [
      fira-code-symbols
      fira-code
      google-fonts
      inconsolata-nerdfont
      inconsolata-lgc
      liberation_ttf
      libre-caslon
      navilu-font
      nerdfonts
      pecita
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

  programs = {
    gnome-terminal.enable = true;
    #gnome-documents.enable = true;
    gnome-disks.enable = true;
    file-roller.enable = true;
    evince.enable = true;
    dconf.enable = true;
    xwayland.enable = lib.mkDefault true;
  };

  environment = {
    variables = {
      ECORE_IMF_MODULE = "fcitx";
    };

    systemPackages = with pkgs; [
      # X utilities **************************
      gnome3.dconf-editor
      barrier
      dex
      ddccontrol
      dunst
      evtest
      feh
      glxinfo
      gnome3.gnome-session
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
      #unstable.anki
      anki-bin
      #blueman
      brasero
      calibre
      dfeet
      #fontmatrix
      gcolor2
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
      poedit
      protonmail-bridge
      rclone
      tigervnc
      unetbootin
      gnomeExtensions.gtile
      gnomeExtensions.timepp
      gnomeExtensions.vitals
      gnomeExtensions.paperwm
      gnomeExtensions.pop-shell
      gnomeExtensions.vertical-overview
      #gnomeExtensions.jiggle

      # network
      networkmanagerapplet
      wireshark

      # guitar
      perl536Packages.AppMusicChordPro
      musescore
      tuxguitar

      # office
      birdtray # tray indicator for thunderbird
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
      gnomeExtensions.just-perfection
      gnomeExtensions.user-themes
      gnomeExtensions.user-themes-x
      gnome.gnome-themes-extra
      gnome.gnome-software
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
      gwenview
      inkscape-with-extensions
      kolourpaint
      krita
      skanlite
      #yed

      # video
      ffmpeg-full

      # video players
      mpv
      smplayer
      vlc

      # web browsers
      microsoft-edge
      chromium
      firefox
      firefox-esr
      tridactyl-native
      # need to update url
      #tor-browser-bundle-bin

      # chat
      #skypeforlinux
      slack
      tdesktop
      zoom-us
    ];
  };

  nixpkgs.config = {
    firefox = firefoxConfig;
  };

  environment.sessionVariables = rec {
    NIXOS_OZONE_WL = "1";
  };

  #hardware.keyboard.zsa.enable = true;
}
# ex: set et ts=2 sw=2 :
