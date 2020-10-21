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
    iperf
    qemu
    samba
    zfstools

    # devel
    awscli
    ansible
    ansible-lint
    awless
    unstable.helm
    ltrace
    rpm
    s3cmd
    vagrant
    winpdb

    # network
    mobile-broadband-provider-info
    modemmanager
    networkmanager_strongswan
    libqmi
    strongswanNM
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
    kdeApplications.krdc
    remmina

    ssvnc

    # GUI *****************************
    citrix_workspace
    thunderbird
    gnome3.vinagre

    # chat
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
