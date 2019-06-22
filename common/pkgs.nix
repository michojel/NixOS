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
    acpi
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

    # filesystems
    bindfs          # for mpd mount
    libxfs
    mtpfs
    xfsprogs

    # CLI **********************************
    aha
    datamash
    expect
    i2c-tools
    imagemagick
    ipcalc
    gnucash
    lftp
    krb5Full.dev
    lsof
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
    binutils-unwrapped    # readelf
    cabal-install
    cabal2nix
    myNodePackages."@google/clasp"
    universal-ctags
    gnumake
    hlint
    mr
    nodePackages.node2nix
    patchelf
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
    dnsmasq
    iftop
    nethogs

    # X utilities **************************
    alarm-clock-applet
    ddccontrol
    dunst
    feh
    glxinfo
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
    firefox-esr
    #firefox-esr-52
    firefoxPackages.tor-browser

    # chat
    pidgin-with-plugins
    skypeforlinux
    tdesktop

    # mistable additions
    megasync
  ];

  nixpkgs.config = {
    firefox = firefoxConfig;

    packageOverrides = pkgs: rec {
      kmymoney = unstable.kmymoney.overrideDerivation (attrs: rec {
        version = "5.0.4";
        name    = "kmymoney-${version}";
        patches = [];
        src     = unstable.fetchurl {
          url    = "mirror://kde/stable/kmymoney/${version}/src/${name}.tar.xz";
          sha256 = "06lbavhl9b8cybnss2mmy3g5w8qn2vl6zhipvbl11lsr3j9bsa8q";
        };
      });

      flashplayer = pkgs.flashplayer.overrideDerivation (attrs: rec {
        version = "32.0.0.192";
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
          sha256 = "1h2ya3szq24dczv2izxy47kr2raiahxx7zvm49jlvlcp5cygxvjk";
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

      megasync = pkgs.callPackage /mnt/nixos/common/megasync.nix {
        pythonBindings = true;
        python         = pkgs.python3;
        ply            = pkgs.python37Packages.ply;
        enableFFmpeg   = true;
        ffmpeg         = pkgs.ffmpeg;
        enableTermcap  = true;
        gpm            = pkgs.gpm;
        ncurses        = pkgs.ncurses;
        readline       = pkgs.readline;
      };

      autorandr = unstable.autorandr.overrideDerivation (attrs: rec {
        src = pkgs.fetchFromGitHub {
          # use dpi branch
          rev = "02e61d00a24beabcc8d0c77ec4cf5b2c6cd826ea";
          owner = "phillipberndt";
          repo = "autorandr";
          sha256 = "1935j6wvhp6k4z0dqjbwssfks83d3c3jjr4mzc5ms9a4wx2wc17q";
        };
      });
    };
  };
}

# ex: set et ts=2 sw=2 :
