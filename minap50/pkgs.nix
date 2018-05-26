{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [

    # filesystems
    bindfs          # for mpd mount
    go-mtpfs
    libmtp
    systemd-cryptsetup-generator

    # cli
    ack
    bind
    ctags
    efibootmgr
    file
    fzf
    gcc
    gnupg
    gnupg1compat
    gptfdisk
    grub2_efi
    hdparm
    htop
    iotop
    jq
    krb5Full
    mc
    ncmpcpp
    nix-repl
    nixUnstable
    mpc_cli
    neovim
    neovim-qt
    pciutils
    pwgen
    silver-searcher
    sshfs-fuse
    tcpdump
    tmux
    tmuxinator
    tree
    vim
    xclip   # dependencies of neovim
    xsel    # dependencies of neovim
    youtube-dl
    wget

    # languages
    python3Full
    # go_1_6
    # go_1_8
    go

    # git
    gitAndTools.git-annex
    gitAndTools.git-annex-remote-rclone
    gitAndTools.git-hub
    gitAndTools.hub

    # services
    mpd
    networkmanager
    redshift
    ympd

    # graphical
    anki
    blink
    chromium
    clipit
    duplicity
    #ekiga
    firefox
    git
    glxinfo
    gnome3.dconf
    gnome3.dconf-editor
    goldendict
    guvcview
    hexchat
    #kmymoney
    st
    tdesktop
    xdotool
    xorg.xev
    xorg.xkill
    xorg.xprop
    xscreensaver

    # fonts
    powerline-fonts
    terminus_font
    terminus_font_ttf
    ubuntu_font_family

    # look
    adapta-backgrounds
    adapta-gtk-theme
    arc-icon-theme
    arc-theme
    greybird
    numix-gtk-theme
    numix-icon-theme
    numix-icon-theme-circle
    numix-icon-theme-square
    paper-gtk-theme
    paper-icon-theme

    # xfce
    xfce.xfce4_clipman_plugin
    xfce.xfce4_xkb_plugin

    # mate
    mate.caja-extensions
    mate.cajaWithExtensions

    # multimedia
    kmplayer
    mpv
    vlc
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    st = pkgs.st.overrideAttrs (attrs: {
      config = builtins.readFile ./pkg-st.config.h;
    });

    openssh = pkgs.appendToName "with-kerberos" (pkgs.openssh.override {
      withKerberos = true; 
    });
  };
}
