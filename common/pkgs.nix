{ config, lib, options, pkgs, nodejs, ... }:

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
  nix.nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=/mnt/nixos/overlays-compat" ];
  nixpkgs = {
    config = {
      # obsoleted by overlays
      packageOverrides = pkgs: rec { };

      # directory with individual overlays in files
      overlays = "/mnt/nixos/overlays-compat";
    };
    overlays = with lib; let
      # inspired by: https://github.com/Infinisil/system/blob/382406251e10412baa6b0fda40bbe22aafd4a86d/config/new-modules/default.nix
      # Recursively constructs an attrset of a given folder, recursing on directories, value of attrs is the filetype
      getDir = dir: mapAttrs
        (
          file: type:
            if type == "directory" then getDir "${dir}/${file}" else type
        )
        (builtins.readDir dir);

      # Collects all files of a directory as a list of strings of paths
      files = dir: collect isString (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

      # Filters out directories that don't end with .nix or are this file, also makes the strings absolute
      validFiles = dir: map (file: dir + "/${file}") (filter
        (
          file: hasSuffix ".nix" file
            && file != "default.nix"
            && (builtins.match "(^|.*/)deps/.*" file == null)
        )
        (files dir));
    in
    map (import) (validFiles /mnt/nixos/overlays);
  };


  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    acpi
    iperf
    nfs-utils
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
    cargo # for pre-commit
    colordiff
    datamash
    ed
    expect
    glances
    i2c-tools
    imagemagickBig
    ipcalc
    jp2a
    fdupes
    gnucash
    gopass-jsonapi
    lftp
    krb5Full.dev
    lsof
    mimeo # similar to xdg-open
    nixos-option
    openssl
    p7zip
    pandoc
    pass
    passExtensions.pass-audit
    passExtensions.pass-genphrase
    passExtensions.pass-import
    passExtensions.pass-update
    gitAndTools.pass-git-helper
    gitAndTools.git-filter-repo
    poppler_utils # pdfunite
    rclone
    rdfind
    safe # for interaction with vault
    scanmem
    symlinks
    tetex
    html-tidy
    tldr
    ts
    vimHugeX
    xdotool
    python3Packages.youtube-dl
    unison
    units
    zsh
    vault
    vaultenv

    # devel
    apacheHttpd # for htpasswd command
    binutils-unwrapped # readelf
    cabal-install
    cabal2nix
    cached-nix-shell
    carnix
    dive
    dos2unix
    # TODO: update to the latest (2.3.0+)
    #unstable.google-clasp
    helmfile
    mustache-go
    nodePackages.eslint
    gnumake
    hlint
    go-jsonnet
    jsonnet
    maturin

    # dev-doc
    glibcInfo
    pinfo
    man-pages
    man-pages-posix
    stdmanpages

    mr
    nixpkgs-fmt
    nixpkgs-review
    #unstable.nix-linter
    # to resolve https://github.com/svanderburg/node2nix/issues/106
    # fixes build of NPM packages containing package-lock.json files
    # needed 1.7.0 version
    nodePackages.node2nix
    patchelf
    pre-commit
    nodePackages.prettier
    #nodePackages.prettier-eslint
    python
    python3Full
    quilt
    remarshal
    rpm
    ruby
    universal-ctags
    yajl
    python3Packages.yamllint

    # hardware
    ddcutil
    dmidecode
    hd-idle
    hdparm
    lshw
    parted

    # network
    dnsmasq
    geoip
    iftop
    nmap
    nethogs
    sshping
  ];

}

# ex: set et ts=2 sw=2 :
