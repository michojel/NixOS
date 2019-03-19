{ config, pkgs, nodejs, ... }:

with config.nixpkgs;
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in rec {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    bindfs          # for mpd mount
    dnsmasq
    docker-distribution
    iperf
    smartmontools
    sstp
    usbutils

    # audio
    mpc_cli
    mpd
    ncmpcpp
    ympd

    # android
    android-file-transfer
    libmtp
    mtpfs

    # CLI **********************************
    datamash
    expect
    i2c-tools
    imagemagick
    ipcalc
    lftp
    krb5Full.dev
    p7zip
    pandoc
    poppler_utils   # pdfunite
    scanmem
    tetex
    tldr
    vimHugeX
    xdotool
    python36Packages.youtube-dl
    unison
    units

    # devel
    cabal-install
    cabal2nix
    myNodePackages."@google/clasp"
    ctags
    gnumake
    hlint
    mr
    nodePackages.node2nix
    python
    python3Full
    ruby

    # hardware
    ddcutil
    dmidecode
    hd-idle
    hdparm
    lshw
    parted

    # X utilities **************************
    alarm-clock-applet
    ddccontrol
    dunst
    feh
    libnotify
    parcellite
    scrot
    xorg.xbacklight
    xorg.xev
    xorg.setxkbmap
    xorg.xhost
    xorg.xkbcomp
    xfontsel
    xlockmore
    xorg.xkill
    xorg.xdpyinfo
    xsel

    # GUI **********************************
    unstable.anki
    brasero
    calibre
    dfeet
    evince
    fontmatrix
    goldendict
    gparted
    unstable.googleearth
    gucharmap
    k3b
    kcharselect
    kmymoney
    libreoffice
    networkmanagerapplet
    neovim-qt
    notepadqq
    pavucontrol
    pdftk
    pinentry_gnome
    redshift
    redshift-plasma-applet
    unetbootin
    xpdf
    xournal

    #webcam
    gnome3.cheese
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
    gnome-breeze
    gnome2.gnome_icon_theme
    kdeApplications.grantleetheme
    greybird
    hicolor-icon-theme
    libsForQt5.kiconthemes
    lxappearance
    lxappearance-gtk3
    lxqt.lxqt-themes
    materia-theme
    numix-cursor-theme
    numix-gtk-theme
    numix-icon-theme
    numix-icon-theme-circle
    numix-icon-theme-square
    profont
    xorg.xcursorthemes

    # fonts
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

    # terminal emulators
    anonymousPro
    cantarell-fonts
    roxterm
    terminator

    # graphics
    gimp
    inkscape

    # video players
    mpv
    smplayer
    vlc

    # web browsers
    # TODO: support gssapi
    # https://dev.chromium.org/administrators/policy-list-3#GSSAPILibraryName
    chromium
    firefox
    firefoxPackages.tor-browser

    # chat
    pidgin-with-plugins
    tdesktop

    # mistable additions
    megasync
  ];

  nixpkgs.config = {
    chromium = {
      enablePepperFlash = true; # Chromium's non-NSAPI alternative to Adobe Flash
      enablePepperPDF = true;
      icedtea = true;   # OpenJDK
    };
    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
      jre = true;       # Oracle's JRE
      #icedtea = true;   # OpenJDK
      gssSupport = true;
    };

    oraclejdk.accept_license = true;

    packageOverrides = pkgs: rec {
      kmymoney = unstable.kmymoney.overrideDerivation (attrs: rec {
        version = "5.0.2";
        name    = "kmymoney-${version}";
        patches = [];
        src     = unstable.fetchurl {
          url    = "mirror://kde/stable/kmymoney/${version}/src/${name}.tar.xz";
          sha256 = "14x5cxfhndv5bjj2m33nsw0m3ij7x467s6jk857c12qyvgmj3wsp";
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

      myNodePackages = import /mnt/nixos/nodejs/composition-v10.nix {
        pkgs = pkgs;
      };

      megasync = pkgs.callPackage /mnt/nixos/common/megasync.nix {};
    };
  };
}

# ex: set et ts=2 sw=2 :
