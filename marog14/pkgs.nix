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
    exfat
    exfatprogs
    iperf
    qemu
    samba
    zfstools

    # HW
    #asusctl
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
    kind
    krew
    kubectl
    kubernetes-helm
    operator-sdk
    controller-tools
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
    directvnc
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
    gnome3.vinagre
    unetbootin
    ventoy

    virtmanager

    # play
    #unstable.wine
    #unstable.winetricks

    # video
    #ffmpeg-sixel
    pitivi

    # browsers
    google-chrome
  ];
}

# ex: set et ts=2 sw=2 :
