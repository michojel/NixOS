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
    oci-runtime-tools
    google-cloud-sdk
    ltrace
    unstable.k0sctl
    kind
    k9s
    krew
    kubectl
    kubernetes-helm
    operator-sdk
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
    rhythmbox
    evolutionWithPlugins
    razergenie
    thunderbird
    gnome3.vinagre
    unetbootin
    ventoy-bin

    virt-manager

    # video
    mkvtoolnix
    mkvtoolnix-cli

    # browsers
    google-chrome
  ];

}

# ex: set et ts=2 sw=2 :
