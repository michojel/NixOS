{ config, pkgs, nodejs, ... }:

with config.nixpkgs;
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

in rec {
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
    rpm
    skopeo
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
    gnome3.vinagre
    thunderbird

    # chat
    unstable.slack
    virtmanager

    # play
    #unstable.wine
    #unstable.winetricks

    # video
    ffmpeg-sixel
    obs-studio
    openshot-qt

    # browsers
    #citrix_workspace
    google-chrome
  ];


  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      ssvnc = pkgs.callPackage /mnt/nixos/common/ssvnc.nix {
            fontDirectories = with pkgs; [ xorg.fontadobe75dpi xorg.fontmiscmisc xorg.fontcursormisc
                xorg.fontbhlucidatypewriter75dpi ];

      };
    };
  };
}

# ex: set et ts=2 sw=2 :
