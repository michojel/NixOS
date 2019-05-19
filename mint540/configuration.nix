# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./zfs.nix
      ./bind-mounts.nix
      /mnt/nixos/common/pkgs.nix
      /mnt/nixos/common/network-manager.nix
      /mnt/nixos/common/external-devices.nix
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
  system.stateVersion       = "19.03";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-19.03";

  time.timeZone = "Europe/Prague";

  networking = {
    hostName = "mint540"; # Define your hostname.
    hostId   = "de93b847";

    networkmanager.enable = true;

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [22];
    firewall.allowedUDPPorts = [];
    firewall.allowPing = true;
  };

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
  };

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
    printing = {
      enable = true;
      drivers = [pkgs.gutenprint pkgs.hplip pkgs.splix];
    };

    udev.extraRules =
      ''
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
    extraGroups  = [
      "networkmanager" "wheel" "audio" "fuse"
      "docker" "utmp" "i2c" "cdrom" "libvirtd"
      "vboxusers" "video"
      ];
  };
  users.extraGroups.i2c = {
    gid          = 546;
  };

  virtualisation.docker.enable          = true;
  virtualisation.docker.enableOnBoot    = true;
  virtualisation.virtualbox.host.enable = true;

  systemd = {
    generator-packages = [ 
      pkgs.systemd-cryptsetup-generator
    ];
  };
}
