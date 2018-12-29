{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    ack
    anki
    bindfs          # for mpd mpunt
    chromium
    cryptsetup
    ctags
    ddccontrol
    duplicity
    file
    gcc
    docker-distribution
    git
    gitAndTools.git-annex
    gitAndTools.git-hub
    gnome2.gnome_keyring
    gnome3.seahorse
    gnupg
    gnupg1compat
    gnumake
    goldendict
    gparted
    hdparm
    hlint
    htop
    i2c-tools
    iperf
    jq
    #kate
    mc
    megatools
    mpc_cli
    mpd
    mpv
    ncmpcpp
    neovim
    neovim-qt
    nix-repl
    parted
    pavucontrol
    pinentry
    pinentry_ncurses
    pinentry_gnome
    profont
    pwgen
    python
    python35Packages.youtube-dl
    python3Full
    redshift
    redshift-plasma-applet
    ruby
    sshfs-fuse
    smplayer
    st
    synergy
    tdesktop
    terminus_font
    terminus_font_ttf
    tmux
    firefoxPackages.tor-browser
    tree
    vimHugeX
    vlc
    wget
    xfce.thunar-archive-plugin
    xfce.thunar_volman
    xfce.xfce4_clipman_plugin
    xfce.xfce4_cpufreq_plugin
    xfce.xfce4_fsguard_plugin
    xfce.xfce4_genmon_plugin
    xfce.xfce4-hardware-monitor-plugin
    xfce.xfce4_mpc_plugin
    xfce.xfce4_pulseaudio_plugin
    xfce.xfce4_xkb_plugin
    xdotool
    xlockmore
    xorg.xkill
    unetbootin
    unzip
    ympd
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    st = pkgs.st.overrideAttrs (attrs: {
      config = builtins.readFile ./pkg-st.config.h;
    });
  };
}
