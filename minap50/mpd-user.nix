{ config, pkgs, ... }:

{
  systemd.user.services.mpd = {
    enable = true;
    description = "Music Player Daemon";
    after = [ "network.target" "sound.target" ];
    environment = {
      DISPLAY = ":0";
    };

    serviceConfig = {
      PermissionsStartOnly = true;
      ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon %h/.config/mpd/mpd.conf";
    };
  };

  services.ympd = {
    enable = true;
    webPort = "6680";
  };
}
