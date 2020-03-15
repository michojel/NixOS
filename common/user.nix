{ config, lib, pkgs, ... }:

{
  users.extraUsers.miminar = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = lib.mkAfter [
      "audio"
      "cdrom"
      "docker"
      "fuse"
      "i2c"
      "jackaudio"
      "libvirtd"
      "networkmanager"
      "utmp"
      "vboxusers"
      "video"
      "wheel"
    ];
  };
  users.extraGroups.i2c = {
    gid = 546;
  };
}

# ex: set et ts=2 sw=2 :
