{ config, pkgs, nodejs, ... }:

with config.nixpkgs;
let
  firefoxConfig = {
      enableGoogleTalkPlugin = true;
      # TODO: resolve curl: (22) The requested URL returned error: 404 Not Found
      #  error: cannot download flash_player_npapi_linux.x86_64.tar.gz from any mirror
      enableAdobeFlash = true;
      icedtea = true;   # OpenJDK
      gssSupport = true;
    };
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
      firefox = firefoxConfig;
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
    aha
    datamash
    expect
    i2c-tools
    imagemagick
    ipcalc
    lftp
    krb5Full.dev
    openssl
    p7zip
    pandoc
    poppler_utils   # pdfunite
    scanmem
    tetex
    tldr
    ts
    vimHugeX
    xdotool
    python36Packages.youtube-dl
    unison
    units
    zsh

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

    # network
    iftop
    nethogs

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
    fontmatrix
    goldendict
    gparted
    unstable.googleearth
    gucharmap
    k3b
    kcharselect
    kmymoney
    neovim-qt
    pavucontrol
    pinentry_gnome
    redshift
    redshift-plasma-applet
    unetbootin

    # network
    networkmanagerapplet
    wireshark

    # office
    evince
    libreoffice
    notepadqq
    pdftk
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
    compton
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
    unstable.enlightenment.terminology

    # graphics
    gimp
    inkscape

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
    firefoxPackages.tor-browser

    # chat
    pidgin-with-plugins
    tdesktop

    # mistable additions
    megasync
  ];

  nixpkgs.config = {
    firefox = firefoxConfig;

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

      flashplayer = pkgs.flashplayer.overrideDerivation (attrs: rec {
        version = "32.0.0.171";
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
          sha256 = "1f3nl4qkws16q2yw940vvb0zmmwxks1blm4ida65hlda6f9zfq3h";
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
