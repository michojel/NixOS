{ config, pkgs, nodejs, ... }:

with config.nixpkgs;
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in
rec {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # CLI *****************************
    duply
    iperf
    qemu
    samba
    zfstools

    # devel
    awscli
    ansible
    ansible-lint
    asciidoc-full
    awless
    helm
    ltrace
    kubernetes-helm
    unstable.operator-sdk
    controller-tools
    kustomize
    rpm
    s3cmd
    skopeo
    vagrant
    winpdb

    # network
    mobile-broadband-provider-info
    modemmanager
    libqmi
    usb_modeswitch
    linuxPackages.usbip
    tightvnc
    gtk-vnc
    gtk-vnc.bin
    gtk-vnc.man
    x11vnc
    directvnc
    x2vnc
    virt-viewer
    #kdeApplications.krdc
    remmina

    ssvnc

    # GUI *****************************
    citrix_workspace
    razergenie
    opera
    thunderbird
    gnome3.vinagre

    # chat
    bluejeans-gui
    hexchat
    slack
    teams
    virtmanager

    # play
    #unstable.wine
    #unstable.winetricks

    # video
    ffmpeg-sixel
    obs-studio

    # browsers
    google-chrome
  ];
}

# ex: set et ts=2 sw=2 :
