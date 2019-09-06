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
    jp2a
    gnucash
    hardlink
    lftp
    krb5Full.dev
    lsof
    mimeo           # similar to xdg-open
    openssl
    p7zip
    pandoc
    pass
    passExtensions.pass-audit
    passExtensions.pass-genphrase
    passExtensions.pass-import
    passExtensions.pass-update
    gitAndTools.pass-git-helper
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
    unstable.google-clasp
    mustache-go
    gnumake
    hlint
    mr
    # to resolve https://github.com/svanderburg/node2nix/issues/106
    # fixes build of NPM packages containing package-lock.json files
    # needed 1.7.0 version
    unstable.nodePackages.node2nix
    patchelf
    python
    python3Full
    quilt
    remarshal
    rpm
    ruby
    universal-ctags
    yajl
    yaml2json

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
    kmymoney
    neovim-qt
    pavucontrol
    pinentry_gnome
    qtpass
    unstable.protonmail-bridge
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
    tor-browser-bundle-bin

    # chat
    pidgin-with-plugins
    skypeforlinux
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
        version = "32.0.0.238";
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
          sha256 = "05gvssjdz43pvgivdngrf8qr5b30p45hr2sr97cyl6b87581qw9s";
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
