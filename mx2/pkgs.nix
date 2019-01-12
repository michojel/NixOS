{ config, pkgs, nodejs, stdenv, ... }:

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
    ack
    unstable.anki
    bindfs          # for mpd mount
    cabal-install
    cabal2nix
    calibre
    clipit
    cryptsetup
    ctags
    ddccontrol
    ddcutil
    duplicity
    file
    #gcc
    docker-distribution
    fontmatrix
    git
    gitAndTools.git-hub
    #gnome2.gnome_keyring
    #gnome3.seahorse
    gnupg
    gnumake
    goldendict
    gparted
    hdparm
    hlint
    htop
    i2c-tools
    imagemagick
    iperf
    jq
    #kate
    mc
    megatools
    myNodePackages."@google/clasp"
    neovim
    neovim-qt
    networkmanagerapplet
    nodePackages.node2nix
    parted
    parcellite
    pavucontrol
    pinentry
    pinentry_ncurses
    pinentry_gnome
    profont
    pwgen
    python
    python36Packages.youtube-dl
    python3Full
    ruby
    smartmontools
    sshfs-fuse
    #synergy
    unetbootin
    unison
    unzip

    # audio
    mpc_cli
    mpd
    ncmpcpp
    ympd

    # CLI **********************************
    tmux
    tree
    vimHugeX
    xdotool
    wget

    # X utilities **************************
    dunst
    i3lock-color
    libnotify
    scrot
    xorg.xbacklight
    xorg.xev
    xfontsel
    xlockmore
    xorg.xkill
    xorg.xdpyinfo
    xsel

    # GUI **********************************
    brasero
    unstable.googleearth
    k3b
    kmymoney
    notepadqq
    redshift
    redshift-plasma-applet

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

      megasync = pkgs.callPackage ./megasync.nix {};

      # TODO: make this work
      # TODO: move this into a shared file
      xorg = pkgs.xorg // rec {
        xkeyboardconfig_vok = pkgs.xorg.xkeyboardconfig.overrideAttrs (attrs: {
              srcs = [attrs.src (pkgs.fetchFromGitLab {
                owner = "vojta_vogo";
                repo = "vok";
                rev = "9b338e5c8859830e09157e5e70498f65f980e3b2";
                sha256 = "1mz5dpizlkz858nv41dsi9idd7m9a4jgbwgld6lwklmaxg8qmadi";
              })];
          sourceRoot = attrs.name;
          postInstall = attrs.postInstall + ''
            install -m 0644 "../source/xorg/vok" "$out/share/X11/xkb/symbols"
          '';
        });

        xorgserver = pkgs.xorg.xorgserver.overrideAttrs (old: {
          configureFlags = old.configureFlags ++ [
            "--with-xkb-bin-directory=${xkbcomp}/bin"
            "--with-xkb-path=${xkeyboardconfig_vok}/share/X11/xkb"
          ];
        });

        setxkbmap = pkgs.xorg.setxkbmap.overrideAttrs (old: {
          postInstall =
            ''
              mkdir -p $out/share
              ln -sfn ${xkeyboardconfig_vok}/etc/X11 $out/share/X11
            '';
        });

        xkbcomp = pkgs.xorg.xkbcomp.overrideAttrs (old: {
          configureFlags = "--with-xkb-config-root=${xkeyboardconfig_vok}/share/X11/xkb";
        });
    };

    xkbvalidate = pkgs.xkbvalidate.override {
      libxkbcommon = pkgs.libxkbcommon.override {
        xkeyboard_config = xorg.xkeyboardconfig_vok;
      };
    };
  };
}

# ex: set et ts=2 sw=2 :
