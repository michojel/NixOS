{ config, pkgs, ... }:

{
  systemd.user.services.xscreensaver = {
    enable = true;
    description = "A modular screen saver and locker for the X Window System.";
    after = ["graphical.target" ];
    environment = {
      DISPLAY = ":0";
    };

    serviceConfig = {
      PermissionsStartOnly = true;
      ExecStartPre = "${pkgs.xscreensaver}/bin/xscreensaver-command -exit";
      ExecStart = "${pkgs.xscreensaver}/bin/xscreensaver -no-splash";
      ExecStartStop = "${pkgs.xscreensaver}/bin/xscreensaver-command -exit";
      Restart = "always";
      RestartSec = 1;
    };
  };
}
