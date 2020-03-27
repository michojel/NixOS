{ config, options, pkgs, nodejs, ... }:

with config.nixpkgs;
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in
rec {

  # Copied from: https://nixos.wiki/wiki/Overlays
  # With existing `nix.nixPath` entry:
  nix.nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/mnt/nixos/overlays-compat/" ];
  nixpkgs.config = {
    # obsoleted by overlays
    packageOverrides = pkgs: rec {};

    # directory with individual overlays in files
    overlays = "/mnt/nixos/overlays";
  };


  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    acpi
    iperf
    nfsUtils
    smartmontools
    sstp
    usbutils

    # audio
    mpc_cli
    mpd
    ncmpcpp
    ympd

    # android
    android-file-transfer
    libmtp

    # filesystems
    bindfs # for mpd mount
    libxfs
    mtpfs
    xfsprogs

    # CLI **********************************
    aha
    unstable.cargo # for pre-commit
    datamash
    expect
    i2c-tools
    imagemagick
    ipcalc
    jp2a
    fdupes
    gnucash
    hardlink
    lftp
    krb5Full.dev
    lsof
    mimeo # similar to xdg-open
    openssl
    p7zip
    pandoc
    pass
    passExtensions.pass-audit
    passExtensions.pass-genphrase
    passExtensions.pass-import
    passExtensions.pass-update
    gitAndTools.pass-git-helper
    poppler_utils # pdfunite
    rdfind
    scanmem
    tetex
    tldr
    ts
    vimHugeX
    xdotool
    python36Packages.youtube-dl
    unison
    units
    zsh

    # devel
    binutils-unwrapped # readelf
    cabal-install
    cabal2nix
    # TODO: update to the latest (2.3.0+)
    #unstable.google-clasp
    mustache-go
    gnumake
    hlint
    mr
    unstable.nixpkgs-fmt
    unstable.nix-review
    #unstable.nix-linter
    # to resolve https://github.com/svanderburg/node2nix/issues/106
    # fixes build of NPM packages containing package-lock.json files
    # needed 1.7.0 version
    unstable.nodePackages.node2nix
    patchelf
    unstable.pre-commit
    python
    python3Full
    quilt
    remarshal
    rpm
    ruby
    universal-ctags
    yajl

    # hardware
    ddcutil
    dmidecode
    hd-idle
    hdparm
    lshw
    parted

    # network
    dnsmasq
    iftop
    nethogs
  ];

}

# ex: set et ts=2 sw=2 :
