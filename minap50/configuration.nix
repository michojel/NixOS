# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./remote-mountpoints.nix
      ./removable-mountpoints.nix
      ./bind-mounts.nix
      ./pkgs.nix
      ./shell.nix
      ./kerberos.nix
      ./docker.nix
      ./mpd-user.nix
      ./xscreensaver-user.nix
    ];

  nix.nixPath = [
    "nixpkgs=/etc/nixos/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
    "/etc"
  ];

  nixpkgs.config.allowUnfree = true;

  boot.supportedFilesystems = [ "zfs" ];

  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/EFI";
    timeout = 2;
    grub = {
      enable = true;
      device = "nodev"; 
      version = 2;
      efiSupport = true;
      useOSProber = true;
    };
  };

  networking = {
    hostId = "c0086b04";
    hostName = "minap50"; # Define your hostname.
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ... ];
    };
    networkmanager = {
      enable = true;
      useDnsmasq = true;
    };
  };

  i18n = {
    # consoleUseXkbConfig = true;
    consoleFont      = "Lat2-Terminus16";
    consoleKeyMap    = "us";
    #defaultLocale    = "de_DE.UTF-8";
    defaultLocale    = "en_US.UTF-8";
    supportedLocales =
      [ "de_DE.UTF-8/UTF-8"
        "de_AT.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        "cs_CZ.UTF-8/UTF-8"
      ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  environment.variables = {
    GOROOT = [ "${pkgs.go.out}/share/go" ];
  }

  programs = {
    adb.enable = true;
    chromium = {
      enable = true;
      extraOpts = {
        AuthNegotiateDelegateWhitelist = ".redhat.com,.REDHAT.COM,*.redhat.com,*.REDHAT.COM";
        AuthServerWhitelist = ".redhat.com,.REDHAT.COM,*.redhat.com,*.REDHAT.COM";
      };
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    wireshark = {
      enable = true;
      package = pkgs.wireshark-gtk;
    };
  };

  services = {
    accounts-daemon.enable = true;
    hoogle. enable = true;
    openssh.enable = true;
    printing.enable = true;
    sshd.enable = true;

    xserver = {
      enable = true;
      exportConfiguration = true;

      #useGlamor = true; 	# to make sddm work
      displayManager.lightdm = {
        enable = true;
        greeters.gtk.indicators = [
	   "~host" "~spacer" "~clock" "~spacer" "~session" "~language" "~a11y" "~power"
        ];
      };
      desktopManager.xfce.enable = true;
      desktopManager.mate.enable = true;
      
      videoDrivers = [ "nvidia" ];

      layout = "us,cz";
      xkbVariant = ",qwerty";
      xkbOptions = "grp:shift_caps_toggle,terminate:ctrl_alt_bksp,grp:switch,grp_led:scroll";

      libinput = {
        enable = true;
        clickMethod = "none";
        tapping = false;
      };

      inputClassSections = [
          ''
            Identifier       "Logitech Trackball"
            Driver           "libinput"
            MatchProduct     "Trackball"
            MatchIsPointer   "on"
            MatchDevicePath  "/dev/input/event*"
            Option           "ButtonMapping"      "1 8 3 4 5 6 7 2 9"
            Option           "ScrollButton"       "9"
            Option           "ScrollMethod"       "button"
          ''
        ];
    };
    
    udev = {
      extraHwdb =
        ''
          evdev:name:ThinkPad Extra Buttons:dmi:bvn*:bvr*:bd*:svnLENOVO*:pn*
            KEYBOARD_KEY_1a=f21
        '';
      extraRules =
        ''
          SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="54:e1:ad:8f:73:1f", NAME="net0"
          SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="42:01:81:9e:82:23", NAME="wlan0"

          # spin down external rotating disk after 3 minutes of inactivity
          ACTION=="add|change", KERNEL=="sd[b-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -B 50 -S 36 /dev/%k"

          # do not show some partitions in desktop browsers
          # /dev/nvme0n1p6 (windows root)
          ENV{ID_FS_UUID}=="BC381DB3381D6DA0", ENV{UDISKS_IGNORE}="1"
          # /dev/nvme0n1p1 (windows data)
          ENV{ID_FS_UUID}=="12CC1FBDCC1F9A55", ENV{UDISKS_IGNORE}="1"
          # /dev/nvme0n1p2 (windows recovery)
          ENV{ID_FS_UUID}=="3E0E55840E5535DD", ENV{UDISKS_IGNORE}="1"
          # encrypted extdata
          ENV{ID_FS_UUID}=="3c9dda76-333e-4d46-884f-2f90f88e09c0", ENV{UDISKS_IGNORE}="1"
        '';
    };
  };

  users.extraUsers.miminar = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "fuse" "docker" "audio" "adbusers" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?

  systemd.services.rfkill.enable = true;

  security = {
    pki.certificateFiles = [
      "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "/etc/ca-certificates/trust-source/anchors/rh-it-root-ca.pem"
    ];
  };

  virtualisation.docker.extraOptions = "--registry-mirror=http://127.0.0.1:5001";

  fonts.enableDefaultFonts = true;

}

# vim: set ts=2 sw=2 :
