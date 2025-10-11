{ config, pkgs, nodejs, lib, ... }:

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
    exfat
    exfatprogs
    iperf
    qemu
    samba
    zfstools
    dvdplusrwtools

    # HW
    #asusctl
    clinfo
    inxi
    radeontop
    supergfxctl
    vulkan-tools

    # devel
    awscli
    ansible
    ansible-lint
    asciidoc-full
    ltrace
    unstable.kind
    krew
    kubectl
    kubernetes-helm
    operator-sdk
    kustomize
    rpm
    s3cmd
    skopeo
    texlive.combined.scheme-full
    #vagrant

    # network
    mobile-broadband-provider-info
    modemmanager
    libqmi
    libreswan
    usb-modeswitch
    linuxPackages.usbip
    # insecure
    #tightvnc
    gtk-vnc
    gtk-vnc.bin
    gtk-vnc.man
    x11vnc
    x2vnc
    virt-viewer
    #kdeApplications.krdc
    remmina

    #ssvnc

    # GUI *****************************
    #unstable.gnomeExtensions.asusctl-gex
    razergenie
    #opera
    thunderbird
    gnome-connections
    remmina
    unetbootin

    virt-manager

    # play
    #unstable.wine
    #unstable.winetricks

    # video
    #ffmpeg-sixel
    pitivi

    # browsers
    google-chrome
  ];

  nixpkgs.config = {
    permittedInsecurePackages = lib.mkAfter [
      # required by obsidian
      "electron-25.9.0"
      "python-2.7.18.8"
    ];
  };

}

# ex: set et ts=2 sw=2 :
