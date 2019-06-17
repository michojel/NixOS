{ config, lib, pkgs, ... }:

{
  users.extraUsers.miminar = {
    isNormalUser = true;
    uid          = 1000;
    extraGroups  = lib.mkAfter [
      "networkmanager" "wheel" "audio" "fuse"
      "docker" "utmp" "i2c" "cdrom" "libvirtd"
      "vboxusers" "video"
    ];
  };
  users.extraGroups.i2c = {
    gid          = 546;
  };
}

# ex: set et ts=2 sw=2 :
