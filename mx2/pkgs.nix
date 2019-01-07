{ config, pkgs, nodejs, stdenv, ... }:

with config.nixpkgs; 
let
  unstable = import <nixos-unstable> {};
in rec {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    ack
    unstable.anki
    bindfs          # for mpd mount
    cabal2nix
    calibre
    chromium
    clipit
    cryptsetup
    ctags
    ddccontrol
    duplicity
    file
    #gcc
    docker-distribution
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
    #  failing gpgme test
    kmymoney
    mc
    megatools
    mpc_cli
    mpd
    mpv
    myNodePackages."@google/clasp"
    ncmpcpp
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
    redshift
    redshift-plasma-applet
    ruby
    sshfs-fuse
    smplayer
    st
    #synergy
    tdesktop
    terminus_font
    terminus_font_ttf
    tmux
    firefoxPackages.tor-browser
    tree
    vimHugeX
    vlc
    wget
#    xfce.thunar-archive-plugin
#    xfce.thunar_volman
#    xfce.xfce4_clipman_plugin
#    xfce.xfce4_cpufreq_plugin
#    xfce.xfce4_fsguard_plugin
#    xfce.xfce4_genmon_plugin
#    xfce.xfce4-hardware-monitor-plugin
#    xfce.xfce4_mpc_plugin
#    xfce.xfce4_pulseaudio_plugin
#    xfce.xfce4_xkb_plugin
    xdotool
    xlockmore
    xorg.xkill
    unetbootin
    unison
    unzip
    ympd
  ];

  nixpkgs.config.packageOverrides = pkgs: {
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

    lxqt = unstable.lxqt;
  };
}
