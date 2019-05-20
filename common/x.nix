{ config, lib, pkgs, ... }:

{
  imports = [ ./screensaver.nix ];

  services = {
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
        lxqt.enable = true;
        default = "lxqt";
      };

      displayManager.sddm.enable = true;
    };

    autorandr.enable = true;
  };

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
  };

  systemd.user.services.autorandr.wantedBy = ["graphical-session.target"];
  systemd.services.autorandr.wantedBy = ["graphical-session.target"];
}

# ex: set et ts=2 sw=2 :
