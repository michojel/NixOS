{ config, lib, pkgs, ... }:

with config.nixpkgs;
let
  firefoxConfig = {
    enableGnomeExtensions = true;
    enableGoogleTalkPlugin = true;
    # TODO: resolve curl: (22) The requested URL returned error: 404 Not Found
    #  error: cannot download flash_player_npapi_linux.x86_64.tar.gz from any mirror
    enableAdobeFlash = true;
    icedtea = true; # OpenJDK
    gssSupport = true;
  };
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
      firefox = firefoxConfig;
    };
  };

in
rec {
  imports = [ ./xcompose.nix ];

  i18n = {
    consoleUseXkbConfig = true;
    inputMethod.enabled = "uim";
    inputMethod.uim.toolbar = "gtk3-systray";
    extraLocaleSettings = {
      LC_TIME = "cs_CZ.UTF-8";
    };
  };

  services = {
    xserver = {
      enable = true;

      layout = "us,ru";
      xkbVariant = "cz_sk_de,";
      xkbOptions = "grp:shift_caps_toggle,terminate:ctrl_alt_bksp,compose:prsc";

      libinput = {
        enable = true;
        clickMethod = "none";
        naturalScrolling = true;
        tapping = false;
      };

      wacom.enable = true;

      config =
        ''
          Section           "InputClass"
            Identifier      "Logitech Trackball"
            Driver          "evdev"
            MatchProduct    "Trackball"
            MatchIsPointer  "on"
            MatchDevicePath "/dev/input/event*"
            Option          "ButtonMapping"      "1 8 3 4 5 6 7 2 9"
            Option          "EmulateWheel"       "True"
            Option          "EmulateWheelButton" "9"
            Option          "XAxisMapping"       "6 7"
          EndSection
        '';

      # create a symlink target /etc/X11/xorg.conf
      exportConfiguration = true;

      desktopManager = {
        gnome3.enable = true;
      };

      displayManager.gdm = {
        enable = true;
        wayland = false;
      };
    };

    # gnome related
    gnome3 = {
      at-spi2-core.enable = true;
      chrome-gnome-shell.enable = true;
      core-os-services.enable = true;
      core-shell.enable = true;
      core-utilities.enable = true;
      evolution-data-server.enable = true;
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
      gnome-remote-desktop.enable = true;
      gnome-settings-daemon.enable = true;
      gnome-user-share.enable = true;
      sushi.enable = true;
      tracker.enable = true;
      tracker-miners.enable = true;
    };
  };

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
    fonts = with pkgs; lib.mkAfter [
      fira-code-symbols
      fira-code
      google-fonts
      inconsolata-lgc
      liberation_ttf
      powerline-fonts
      profont
      source-sans-pro
      source-serif-pro
      terminus_font
      terminus_font_ttf
      ubuntu_font_family
    ];
  };

  qt5.platformTheme = "gnome";

  programs = {
    gnome-terminal.enable = true;
    gnome-documents.enable = true;
    gnome-disks.enable = true;
    file-roller.enable = true;
    evince.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # X utilities **************************
    alarm-clock-applet
    gnome3.dconf-editor
    ddccontrol
    dunst
    feh
    glxinfo
    gnome3.gnome-session
    libnotify
    scrot
    wmctrl
    xorg.xbacklight
    xorg.xclock
    xclip
    xorg.xeyes
    xorg.xev
    xorg.setxkbmap
    xorg.xhost
    xorg.xkbcomp
    xorg.xmodmap
    xfontsel
    xlockmore
    xorg.xkill
    xorg.xdpyinfo
    xsel

    # GUI **********************************
    anki
    blueman
    brasero
    calibre
    dfeet
    fontmatrix
    goldendict
    gparted
    unstable.googleearth
    gucharmap
    k3b
    kcharselect
    kwin
    pinentry_gnome
    qtpass
    unstable.protonmail-bridge
    redshift
    redshift-plasma-applet
    tigervnc
    unetbootin

    # network
    networkmanagerapplet
    wireshark

    # audio
    ardour
    audacity
    pavucontrol
    qjackctl

    # office
    evince
    kdeApplications.okular
    libreoffice
    notepadqq
    pdf-quench
    # TODO: not yet in stable as of 19.09
    unstable.pdfarranger
    pdftk
    thunderbird
    xpdf
    xournal

    # editors
    # TODO: re-enable - not yet available in the stable channel as of 19.09
    #unstable.gnvim
    neovim-qt

    #webcam
    gnome3.cheese
    fswebcam
    wxcam

    # look
    adapta-gtk-theme
    adapta-kde-theme
    gnome3.adwaita-icon-theme
    arc-icon-theme
    arc-kde-theme
    arc-theme
    capitaine-cursors
    clearlooks-phenix
    compton
    gnome-breeze
    gnome3.gnome-tweaks
    kdeApplications.grantleetheme
    greybird
    hicolor-icon-theme
    materia-theme
    numix-cursor-theme
    numix-gtk-theme
    numix-icon-theme
    numix-icon-theme-circle
    numix-icon-theme-square
    profont
    xorg.xcursorthemes

    # terminal emulators
    anonymousPro
    cantarell-fonts
    roxterm
    terminator

    # graphics
    digikam
    gimp
    gwenview
    inkscape-gs
    kolourpaint
    krita
    pstoedit-gs
    skanlite

    # video
    ffmpeg-full

    # video players
    mpv
    smplayer
    vlc

    # web browsers
    # TODO: support gssapi
    # https://dev.chromium.org/administrators/policy-list-3#GSSAPILibraryName
    chromium
    firefox
    firefox-esr
    # need to update url
    #tor-browser-bundle-bin

    # chat
    pidgin-with-plugins
    unstable.skypeforlinux
    tdesktop

    megasync
  ];



  nixpkgs.config = {
    firefox = firefoxConfig;

    packageOverrides = pkgs: rec {
      # To update:
      #   1. visit https://get.adobe.com/cz/flashplayer/
      #   2. copy the version string to the version attribute down below
      #   3. run nix-prefetch-url --unpack https://fpdownload.adobe.com/get/flashplayer/pdc/${version}/flash_player_npapi_linux.$(uname -m).tar.gz
      #   4. update the sha256 field
      flashplayer = pkgs.flashplayer.overrideDerivation (
        attrs: rec {
          version = "32.0.0.344";
          name = "flashplayer-${version}";
          src = pkgs.fetchurl {
            url = let
              arch =
                if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
                  "x86_64"
                else if pkgs.stdenv.hostPlatform.system == "i686-linux" then
                  "i386"
                else throw "Flash Player is not supported on this platform";
            in
              "https://fpdownload.adobe.com/get/flashplayer/pdc/${version}/flash_player_npapi_linux.${arch}.tar.gz";
            sha256 = "1ki3i7zw0q48xf01xjfm1mpizc5flk768p9hqxpg881r4h65dh6b";
          };
        }
      );

      inkscape-gs = (
        pkgs.inkscape.override {
          imagemagick = pkgs.imagemagickBig;
        }
      ).overrideDerivation (
        attrs: with pkgs; rec {
          buildInputs = attrs.buildInputs ++ [ ghostscript ];
          runtimeDependencies = (lib.attrByPath [ "runtimeDependencies" ] [] attrs) ++ [ pstoedit-gs ];
          postInstall = attrs.postInstall + ''
            wrapProgram $out/bin/inkscape --prefix PATH : "${stdenv.lib.makeBinPath [ pstoedit-gs ]}"
          '';
        }
      );

      pstoedit-gs = (
        pkgs.pstoedit.override {
          imagemagick = pkgs.imagemagickBig;
        }
      ).overrideDerivation (
        attrs: with pkgs; rec {
          buildInputs = attrs.buildInputs ++ [ makeWrapper ];
          runtimeDependencies = (lib.attrByPath [ "runtimeDependencies" ] [] attrs) ++ [ ghostscript ];
          postInstall = (lib.attrByPath [ "postInstall" ] "" attrs) + ''
            wrapProgram $out/bin/pstoedit --prefix PATH : "${stdenv.lib.makeBinPath [ ghostscript ]}"
          '';
        }
      );

      pidgin-with-plugins = pkgs.pidgin-with-plugins.override {
        plugins = with pkgs; [
          pidgin-sipe
          pidgin-skypeweb
          purple-facebook
          purple-hangouts
          purple-matrix
          purple-plugin-pack
          telegram-purple
        ];
      };

      megasync = unstable.libsForQt5.callPackage ./megasync {};

      ffado = pkgs.libsForQt5.callPackage ./ffado {
        inherit (pkgs.linuxPackages) kernel;
      };
      libffado = ffado;

      jack2 = pkgs.jack2.override {
        libffado = libffado;
      };

      #jack2Full = jack2;
      #libjack2 = jack2.override { prefix = "lib"; };

      #      qjackctl = unstable.qjackctl.override {
      #        libjack2 = pkgs.libjack2;
      #      };
    };
  };
}
# ex: set et ts=2 sw=2 :
