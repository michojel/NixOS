{ config, ... }:

{
  fileSystems."/etc/nixos/nixpkgs" =
    { device = "/mnt/minap50root/etc/nixos/nixpkgs";
      noCheck = true;
      options = [
        "bind"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-minap50root.mount"
        "x-systemd.after=mnt-minap50root.mount"
      ]; 
    };

  fileSystems."/etc/nixos/minap50" =
    { device = "/mnt/minap50root/etc/nixos";
      noCheck = true;
      options = [
        "bind"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-minap50root.mount"
        "x-systemd.after=mnt-minap50root.mount"
      ]; 
    };

  fileSystems."${config.services.mpd.musicDirectory}" =
    { device = "/home/miminar/Audio";
      noCheck = true;
      fsType = "fuse.bindfs";
      options = [
        "nofail"
        "map=miminar/mpd:@users/@mpd"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-minap50root.mount"
        "x-systemd.after=mnt-minap50root.mount"
      ];
    };

  fileSystems."/home/miminar/wsp/nixos/minap50" =
    { device = "/mnt/minap50root/etc/nixos";
      noCheck = true;
      fsType = "fuse.bindfs";
      options = [
        "nofail"
        "map=root/miminar:@root/@users"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-minap50root.mount"
        "x-systemd.after=mnt-minap50root.mount"
      ];
    };

  fileSystems."/home/miminar/wsp/nixos/nixosmounter" =
    { device = "/etc/nixos";
      noCheck = true;
      fsType = "fuse.bindfs";
      options = [
        "nofail"
        "map=root/miminar:@root/@users"
      ];
    };

  fileSystems."/home/miminar/wsp/nixos/nixpkgs" =
    { device = "/mnt/minap50root/etc/nixos/nixpkgs";
      noCheck = true;
      fsType = "fuse.bindfs";
      options = [
        "nofail"
        "map=root/miminar:@root/@users"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-minap50root.mount"
        "x-systemd.after=mnt-minap50root.mount"
      ];
    };

#
#  fileSystems."/mnt/minap50root/proc" =
#    { device = "proc";
#      fsType = "proc";
#      noCheck = true;
#      options = [
#        "nofail"
#	"x-systemd.device-timeout=2s"
#	"x-systemd.requires=mnt-minap50root.mount"
#	"x-systemd.after=mnt-minap50root.mount"
#      ];
#    };
#
#  fileSystems."/mnt/minap50root/sys" =
#    { device = "sysfs";
#      fsType = "sysfs";
#      noCheck = true;
#      options = [
#        "nofail"
#	"x-systemd.device-timeout=2s"
#	"x-systemd.requires=mnt-minap50root.mount"
#	"x-systemd.after=mnt-minap50root.mount"
#      ];
#    };
#
#  fileSystems."/mnt/minap50root/dev" =
#    { device = "/dev";
#      noCheck = true;
#      options = [
#	"bind"
#        "nofail"
#	"x-systemd.device-timeout=2s"
#	"x-systemd.requires=mnt-minap50root.mount"
#	"x-systemd.after=mnt-minap50root.mount"
#      ]; 
#    };
#
#  fileSystems."/mnt/minap50root/tmp" =
#    { device = "tmpfs";
#      fsType = "tmpfs";
#      options = [
#        "nofail"
#	"x-systemd.device-timeout=2s"
#	"x-systemd.requires=mnt-minap50root.mount"
#	"x-systemd.after=mnt-minap50root.mount"
#      ]; 
#    };
}

# vim: set et ts=2 sw=2 ft=nix :
