{ config, lib, pkgs, ... }:

with config.nixpkgs;
let
  firefoxConfig = {
      enableGnomeExtensions  = true;
      enableGoogleTalkPlugin = true;
      # TODO: resolve curl: (22) The requested URL returned error: 404 Not Found
      #  error: cannot download flash_player_npapi_linux.x86_64.tar.gz from any mirror
      enableAdobeFlash = true;
      icedtea          = true;   # OpenJDK
      gssSupport       = true;
    };
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
      firefox     = firefoxConfig;
    };
  };

in rec {
  #imports = [ ./screensaver.nix ];

  imports = [ ./xcompose.nix ];

  i18n = {
    consoleUseXkbConfig = true;
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
      xkbOptions = "grp:shift_caps_toggle,terminate:ctrl_alt_bksp,compose:prsc";

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
        #lxqt.enable = true;
        #default = "lxqt";
        #plasma5.enable = true;
        gnome3.enable = true;
      };

      #displayManager.sddm.enable = true;
      #displayManager.sddm.enable = true;
      displayManager.gdm = {
        enable  = true;
        wayland = false;
      };
    };

    # buggy
    #autorandr.enable = true;

    # gnome related
    gnome3                         = {
      at-spi2-core.enable          = true;
      chrome-gnome-shell.enable    = true;
      core-os-services.enable      = true;
      core-shell.enable            = true;
      core-utilities.enable        = true;
      evolution-data-server.enable = true;
      glib-networking.enable       = true;
      gnome-keyring.enable         = true;
      gnome-online-accounts.enable = true;
      gnome-remote-desktop.enable  = true;
      gnome-settings-daemon.enable = true;
      gnome-user-share.enable      = true;
      sushi.enable                 = true;
      tracker.enable               = true;
      tracker-miners.enable        = true;
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

  #systemd.user.services.autorandr.wantedBy = lib.mkAfter ["graphical-session.target"];
  #systemd.services.autorandr.wantedBy      = lib.mkAfter ["graphical-session.target"];

  qt5.platformTheme                = "gnome";

  programs = {
    gnome-terminal.enable = true;
    gnome-documents.enable = true;
    gnome-disks.enable = true;
    file-roller.enable = true;
    evince.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # X utilities **************************
    alarm-clock-applet
    gnome3.dconf-editor
    ddccontrol
    dunst
    feh
    glxinfo
    libnotify
    scrot
    wmctrl
    xorg.xbacklight
    xorg.xclock
    xorg.xeyes
    xorg.xev
    xorg.setxkbmap
    xorg.xhost
    xorg.xkbcomp
    xorg.xmodmap
    xfontsel
    xlockmore
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
    unstable.googleearth
    gucharmap
    k3b
    kcharselect
    kwin
    pavucontrol
    pinentry_gnome
    qtpass
    unstable.protonmail-bridge
    redshift
    redshift-plasma-applet
    tigervnc
    unetbootin

    # network
    networkmanagerapplet
    wireshark

    # office
    evince
    kdeApplications.okular
    libreoffice
    notepadqq
    pdftk
    thunderbird
    xpdf
    xournal

    # editors
    unstable.gnvim
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
    #gnome2.gnome_icon_theme
    gnome3.gnome-tweaks
    kdeApplications.grantleetheme
    greybird
    hicolor-icon-theme
    #libsForQt5.kiconthemes
    #lxappearance
    #lxappearance-gtk3
    #lxqt.lxqt-themes
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

    # graphics
    digikam
    gimp
    gwenview
    inkscape
    kolourpaint
    krita
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
    #unstable.tor-browser-bundle-bin

    # chat
    pidgin-with-plugins
    unstable.skypeforlinux
    tdesktop

    # mistable additions
    unstable.megasync
  ];



  nixpkgs.config = {
    firefox = firefoxConfig;

    packageOverrides = pkgs: rec {
      # To update:
      #   1. visit https://get.adobe.com/cz/flashplayer/
      #   2. copy the version string to the version attribute down below
      #   3. run nix-prefetch-url --unpack https://fpdownload.adobe.com/get/flashplayer/pdc/${version}/flash_player_npapi_linux.$(uname -m).tar.gz
      #   4. update the sha256 field
      flashplayer = pkgs.flashplayer.overrideDerivation (attrs: rec {
        version = "32.0.0.303";
        name = "flashplayer-${version}";
        src = pkgs.fetchurl {
          url = let
            arch =
              if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
                "x86_64"
              else if pkgs.stdenv.hostPlatform.system == "i686-linux"   then
                "i386"
              else throw "Flash Player is not supported on this platform";
            in "https://fpdownload.adobe.com/get/flashplayer/pdc/${version}/flash_player_npapi_linux.${arch}.tar.gz";
          sha256 = "0x0mabgswly2v8z13832pkbjsv404aq61pback6sgmp2lyycdg6w";
        };
      });

      pidgin-with-plugins = pkgs.pidgin-with-plugins.override {
        plugins = with pkgs; [
          pidgin-sipe
          pidgin-skypeweb
          purple-facebook
          purple-hangouts
          purple-matrix
          purple-plugin-pack
          telegram-purple
        ];
      };
    };
  };
}
# ex: set et ts=2 sw=2 :
