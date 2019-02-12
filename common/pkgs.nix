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
    docker-distribution
    iperf
    smartmontools
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
    p7zip
    ddcutil
    i2c-tools
    imagemagick
    hdparm
    parted
    poppler_utils   # pdfunite
    scanmem
    vimHugeX
    xdotool
    python36Packages.youtube-dl
    unison

    # devel
    cabal-install
    cabal2nix
    myNodePackages."@google/clasp"
    ctags
    gnumake
    hlint
    nodePackages.node2nix
    python
    python3Full
    ruby

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
    evince
    fontmatrix
    goldendict
    gparted
    unstable.googleearth
    k3b
    kmymoney
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

  nixpkgs.config.packageOverrides = pkgs: rec {
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
}

# ex: set et ts=2 sw=2 :
