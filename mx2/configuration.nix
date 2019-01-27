# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./bind-mounts.nix
      /mnt/nixos/common/pkgs.nix
      ./mpd-user.nix
      ./remote-mounts.nix
      /mnt/nixos/common/shell.nix
    ];

  nix = {
    gc = {
      automatic = true;
      dates = "19:15";
    };
    maxJobs = 4;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion       = "18.09";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-18.09";

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

  hardware = {
    pulseaudio.enable       = true;
    #pulseaudio.support32Bit = true;
    trackpoint.enable       = true;
  };

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  krb5.enable = true;

  programs = {
    adb.enable            = true;
    chromium.enable       = true;
    dconf.enable          = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };

  services = {
    hoogle.enable   = true;
    openssh.enable  = true;
    printing.enable = true;
    btrfs.autoScrub.enable = true;

    udev.extraRules =
      ''
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="68:f7:28:84:19:04", NAME="net0"
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="aa:03:dd:10:37:eb", NAME="wlan0"
        ACTION=="add", KERNEL=="i2c-[0-9]", GROUP="i2c"
      '';

    smartd = {
      enable = true;
      notifications = {
        x11.enable = true;
        test = true;
      };
    };


    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      layout = "us,cz,ru";
      xkbVariant = ",qwerty,";
      xkbOptions = "grp:shift_caps_toggle,terminate:ctrl_alt_bksp,grp:switch,grp_led:scroll";

      libinput = {
        enable = true;
        clickMethod = "none";
        naturalScrolling = true;
        tapping = false;
      };

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

      desktopManager.lxqt.enable = true;
      desktopManager.default = "lxqt";

      displayManager.sddm.enable = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.miminar = {
    isNormalUser = true;
    uid          = 1000;
    extraGroups  = ["networkmanager" "wheel" "audio" "fuse" "docker" "utmp" "i2c" "cdrom"];
  };
  users.extraGroups.i2c = {
    gid          = 546;
  };

  virtualisation.docker.enable       = true;
  virtualisation.docker.enableOnBoot = true;
}
