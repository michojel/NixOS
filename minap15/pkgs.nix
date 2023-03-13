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
    adb-sync
    adbfs-rootless
    duply
    exfat
    exfatprogs
    iperf
    qemu
    samba
    zfstools

    # devel
    awscli
    asciidoc-full
    google-cloud-sdk
    ltrace
    unstable.k0sctl
    kind
    krew
    kubectl
    kubernetes-helm
    unstable.operator-sdk
    #controller-tools
    #kustomize
    rpm
    s3cmd
    skopeo
    texlive.combined.scheme-full
    vagrant

    # network
    mobile-broadband-provider-info
    modemmanager
    libqmi
    libreswan
    usb-modeswitch
    linuxPackages.usbip
    gtk-vnc
    gtk-vnc.bin
    gtk-vnc.man
    x11vnc
    directvnc
    x2vnc
    virt-viewer
    remmina

    ssvnc

    # GUI *****************************
    evolutionWithPlugins
    razergenie
    thunderbird
    gnome3.vinagre
    unetbootin
    ventoy-bin

    virtmanager

    # video
    mkvtoolnix
    mkvtoolnix-cli

    # browsers
    google-chrome
  ];
}

# ex: set et ts=2 sw=2 :
