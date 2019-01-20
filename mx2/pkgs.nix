{ config, pkgs, nodejs, stdenv, lib, ... }:

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
    #synergy

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
    i2c-tools
    ddcutil
    imagemagick
    hdparm
    parted
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
    i3lock-color
    libnotify
    parcellite
    scrot
    xautolock
    xorg.xbacklight
    xorg.xev
    xorg.setxkbmap
    xfontsel
    xlockmore
    xorg.xkill
    xorg.xdpyinfo
    xsel

    # GUI **********************************
    unstable.anki
    brasero
    calibre
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
    pinentry_gnome
    redshift
    redshift-plasma-applet
    unetbootin

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
    st
    terminator

    # graphics
    gimp
    inkscape

    # video players
    mpv
    smplayer
    vlc

    # web browsers
    chromium
    firefoxPackages.tor-browser

    # chat
    pidgin
    purple-facebook
    purple-hangouts
    purple-plugin-pack
    pidgin-skypeweb
    tdesktop
    telegram-purple
    wire-desktop

    # mistable additions
    megasync
  ];

  nixpkgs.config.packageOverrides = pkgs: rec {
    st = pkgs.st.overrideAttrs (attrs: {
      config = builtins.readFile ./pkg-st.config.h;
    });

    kmymoney = unstable.kmymoney.overrideDerivation (attrs: rec {
      version = "5.0.2";
      name    = "kmymoney-${version}";
      patches = [];
      src     = unstable.fetchurl {
        url    = "mirror://kde/stable/kmymoney/${version}/src/${name}.tar.xz";
        sha256 = "14x5cxfhndv5bjj2m33nsw0m3ij7x467s6jk857c12qyvgmj3wsp";
      };
    });

    myNodePackages = import /mnt/nixos/nodejs/composition-v10.nix {
      pkgs = pkgs;
    };

    megasync = pkgs.callPackage /mnt/nixos/common/megasync.nix {};

    xorg = pkgs.xorg // (import /mnt/nixos/common/vok-keyboard-layout.nix {
      inherit pkgs;
    });
  };
}

# ex: set et ts=2 sw=2 :
