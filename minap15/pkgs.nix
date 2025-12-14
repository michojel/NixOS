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
    brightnessctl
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
    hubble
    ltrace
    unstable.k0sctl
    unstable.kind
    k9s
    krew
    kubectl
    kubernetes-helm
    #manta
    operator-sdk
    #kustomize
    rpm
    s3cmd
    skopeo
    texlive.combined.scheme-full
    vagrant
    neovim-qt
    neovide

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
    x2vnc
    virt-viewer
    remmina

    ssvnc

    # security
    unstable.terrapin-scanner

    # GUI *****************************
    rhythmbox
    evolutionWithPlugins
    razergenie
    thunderbird
    gnome-connections
    unetbootin

    virt-manager

    # video
    mkvtoolnix
    mkvtoolnix-cli

    # browsers
    google-chrome
  ];

  nixpkgs.config = {
    permittedInsecurePackages = lib.mkAfter [
      # required by obsidian
      "electron-25.9.0"
      "python-2.7.18.8"
      "squid-7.0.1"
    ];
  };

}

# ex: set et ts=2 sw=2 :
