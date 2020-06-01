{ config, lib, pkgs, ... }:

with config.nixpkgs;
let
  firefoxConfig = {
    enableGnomeExtensions = true;
    enableGoogleTalkPlugin = true;
    # TODO: resolve curl: (22) The requested URL returned error: 404 Not Found
    #  error: cannot download flash_player_npapi_linux.x86_64.tar.gz from any mirror
    enableAdobeFlash = true;
    icedtea = true; # OpenJDK
    gssSupport = true;
  };

  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
      firefox = firefoxConfig;
    };
  };

  pulseaudio = true;
in
rec {
  imports = [ ./xcompose.nix ];

  console.useXkbConfig = true;

  i18n = {
    inputMethod.enabled = "uim";
    inputMethod.uim.toolbar = "gtk3-systray";
    extraLocaleSettings = {
      LC_TIME = "cs_CZ.UTF-8";
    };
  };

  services = {
    xserver = {
      enable = true;

      layout = "us,ru";
      xkbVariant = "cz_sk_de,";
      xkbOptions = "terminate:ctrl_alt_bksp,grp_led:scroll,lv3:ralt_switch_multikey,nbsp:level3";

      libinput = {
        enable = true;
        clickMethod = "none";
        naturalScrolling = true;
        tapping = false;
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
        gnome3.enable = true;
      };

      displayManager.gdm = {
        enable = true;
        wayland = false;
      };
    };

    # gnome related
    gnome3 = {
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
  };

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
    fonts = with pkgs; lib.mkAfter [
      fira-code-symbols
      fira-code
      google-fonts
      inconsolata-lgc
      liberation_ttf
      powerline-fonts
      profont
      source-sans-pro
      source-serif-pro
      terminus_font
      terminus_font_ttf
      ubuntu_font_family
    ];
  };

  qt5.platformTheme = "gnome";

  programs = {
    gnome-terminal.enable = true;
    gnome-documents.enable = true;
    gnome-disks.enable = true;
    file-roller.enable = true;
    evince.enable = true;
    chromium.extraOpts = {
      AuthNegotiateDelegateWhitelist = "*.redhat.com";
      AuthServerWhitelist = "*.redhat.com";
      GSSAPILibraryName = "${pkgs.kerberos}/lib/libgssapi_krb5.so";
    };
  };

  environment.systemPackages = with pkgs; [
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
    libnotify
    qt512.qttools
    scrot
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
    anki
    blueman
    brasero
    calibre
    dfeet
    fontmatrix
    goldendict
    gparted
    googleearth
    gucharmap
    k3b
    kcharselect
    kwin
    megasync
    pinentry_gnome
    qtpass
    protonmail-bridge
    redshift
    redshift-plasma-applet
    tigervnc
    unetbootin

    # network
    networkmanagerapplet
    wireshark

    # guitar
    musescore
    tuxguitar

    # office
    evince
    kdeApplications.okular
    libreoffice
    notepadqq
    pdf-quench
    # TODO: not yet in stable as of 19.09
    pdfarranger
    pdftk
    thunderbird
    xournal

    # editors
    # TODO: re-enable - not yet available in the stable channel as of 19.09
    #unstable.gnvim
    neovim-qt

    #webcam
    gnome3.cheese
    fswebcam
    wxcam

    # look
    adapta-gtk-theme
    adapta-kde-theme
    gnome3.adwaita-icon-theme
    arc-icon-theme
    arc-kde-theme
    arc-theme
    capitaine-cursors
    clearlooks-phenix
    compton
    gnome-breeze
    gnome3.gnome-tweaks
    kdeApplications.grantleetheme
    greybird
    hicolor-icon-theme
    materia-theme
    numix-cursor-theme
    numix-gtk-theme
    numix-icon-theme
    numix-icon-theme-circle
    numix-icon-theme-square
    profont
    xorg.xcursorthemes

    # terminal emulators
    anonymousPro
    cantarell-fonts
    roxterm
    terminator
    enlightenment.terminology
    tilix

    # graphics
    digikam
    gimp
    gwenview
    inkscape-gs
    kolourpaint
    krita
    pstoedit-gs
    skanlite

    # video
    ffmpeg-full

    # video players
    mpv
    smplayer
    vlc

    # web browsers
    # TODO: support gssapi
    # https://dev.chromium.org/administrators/policy-list-3#GSSAPILibraryName
    chromium
    firefox
    firefox-esr
    # need to update url
    #tor-browser-bundle-bin

    # chat
    pidgin-with-plugins
    skypeforlinux
    tdesktop
  ];

  nixpkgs.config = {
    firefox = firefoxConfig;
  };

  systemd.user.services = {
    devilspie2 = {
      after = [ "graphical.target" "gvfs-daemon.service" "gnome-session-x11.target" ];
      #requires = [ "graphical.target" ];
      wantedBy = [ "default.target" ];
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
