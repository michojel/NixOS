{ config, pkgs, ... }:

let musicDirectory = config.services.mpd.dataDir + "/Music";
in {

  # TODO: make mpd a user service
  systemd.mounts = [
    {
      enable = true;
      before = ["var-lib-mpd-music.mount"];
      what = config.users.extraUsers.miminar.home + "/.config/mpd";
      where = config.services.mpd.dataDir;
      description = "Bind mount of mpd data directory";
      type = "fuse.bindfs";
      options = "nonempty,map=miminar/mpd";
    }

    {
      enable = true;
      after = ["var-lib-mpd.mount"];
      what = config.users.extraUsers.miminar.home + "/Music";
      where = musicDirectory;
      description = "Bind mount of music directory for mpd";
      type = "fuse.bindfs";
      options = "map=miminar/mpd";
    }
  ];

  # TODO: don't hardcode the path
  systemd.services.mpd = {
    after    = ["var-lib-mpd-Music.mount"];
    requires = ["var-lib-mpd-Music.mount"];
  };

  services.mpd = {
    enable = true;
    musicDirectory = musicDirectory;
  };
}
