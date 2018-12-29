# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./pkgs.nix
      ./mpd-user.nix
      ./remote-mounts.nix
      ./synergy.nix
    ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion       = "18.03";
  system.autoUpgrade.enable = true;

  time.timeZone = "Europe/Prague";

  networking = {
    hostName = "mx2"; # Define your hostname.

    networkmanager.enable = true;

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [
      22    # ssh
      5201  # iperf
      24800 # synergy server
    ];
    firewall.allowedUDPPorts = [
      5201  # iperf
      24800 # synergy server
    ];
    firewall.allowPing = true;
  };

  # Select internationalisation properties.
  i18n = {
    # consoleUseXkbConfig = true;
    consoleFont      = "Lat2-Terminus16";
    consoleKeyMap    = "us";
    defaultLocale    = "de_DE.UTF-8";
    supportedLocales =
      [ "de_DE.UTF-8/UTF-8"
        "de_AT.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        "cs_CZ.UTF-8/UTF-8"
      ];
  };

  hardware = {
    pulseaudio.enable       = true;
    pulseaudio.support32Bit = true;
    trackpoint.enable       = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  krb5.enable = true;

  programs = {
    adb.enable            = true;
    bash.enableCompletion = true;
    chromium.enable       = true;
    #vim.defaultEditor     = true;

    tmux = {
      enable              = true;
      clock24             = true;
      historyLimit        = 10000;
      keyMode             = "vi";
      newSession          = true;
      terminal            = "screen-256color";
    };
  };

  nixpkgs.config.allowUnfree = true;

  services = {
    hoogle.enable   = true;
    openssh.enable  = true;
    printing.enable = true;

    udev.extraRules =
      ''
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="68:f7:28:84:19:04", NAME="net0"
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="aa:03:dd:10:37:eb", NAME="wlan0"
      '';


    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      layout     = "us,cz";
      xkbVariant = ",qwerty";
      xkbOptions = "grp:shift_caps_toggle,grp:switch,grp_led:scroll";

      synaptics.enable          = true;
      synaptics.twoFingerScroll = true;

      # adds this input class to the /etc/X11/xorg.conf
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

      # Enable the KDE Desktop Environment.
      #desktopManager.plasma5.enable = true;
      desktopManager.xfce.enable = true;
      desktopManager.mate.enable = true;
      desktopManager.default = "xfce";

      # displayManager.sddm.enable = true;
      # displayManager.lightdm.enable = true;
      # windowManager.xmonad.enable = true;
      displayManager.lightdm.enable = true;
    };

    # desktop effects
    compton = {
      enable          = true;
      fade            = true;
      inactiveOpacity = "0.9";
      shadow          = true;
      fadeDelta       = 4;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.miminar = {
    isNormalUser = true;
    uid          = 1000;
    extraGroups  = ["networkmanager" "wheel" "audio"];
  };

  environment = {
    shells = [pkgs.bashInteractive];
    variables = { EDITOR = lib.mkOverride 900 "nvim"; };
  };


  virtualisation.docker.enable       = true;
  virtualisation.docker.enableOnBoot = true;

  security = {
    sudo.extraConfig = ''
        Defaults:root,%wheel  !tty_tickets
        Defaults:root,%wheel  timestamp_timeout = 10
        Defaults:root,%wheel  env_keep+=EDITOR
      '';
   };

}
