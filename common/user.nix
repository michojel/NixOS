{ config, lib, pkgs, ... }:

{
  users.extraUsers.miminar = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = lib.mkAfter [
      "audio"
      "cdrom"
      "fuse"
      "i2c"
      "jackaudio"
      "libvirtd"
      "networkmanager"
      "plugdev"
      "utmp"
      "vboxusers"
      "video"
      "wheel"
    ];
    shell = pkgs.bashInteractive;
  };
  users.extraGroups.i2c = {
    gid = 546;
  };
}

# ex: set et ts=2 sw=2 :
