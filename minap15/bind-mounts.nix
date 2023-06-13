{ config, ... }:

{
  fileSystems."/etc/nixos" =
    {
      device = "/mnt/nixos/minap15";
      noCheck = true;
      options = [
        "bind"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-nixos.mount"
        "x-systemd.after=mnt-nixos.mount"
        "x-gvfs-hide"
      ];
    };

  fileSystems."/home/${config.local.username}/wsp/nixos" =
    {
      device = "/mnt/nixos";
      noCheck = true;
      fsType = "fuse.bindfs";
      options = [
        "nofail"
        "map=root/${config.local.username}:@root/@users"
        "x-gvfs-hide"
      ];
    };

  fileSystems."/home/miminar/.config/nixpkgs" =
    {
      device = "/mnt/nixos/user";
      noCheck = true;
      options = [
        "nofail"
        "bind"
        "ro"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-nixos.mount"
        "x-systemd.after=mnt-nixos.mount"
        "x-gvfs-hide"
      ];
    };

  fileSystems."/home/miminar/.config/home-manager" =
    {
      device = "/mnt/nixos/home-manager";
      noCheck = true;
      options = [
        "nofail"
        "bind"
        "ro"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-nixos.mount"
        "x-systemd.after=mnt-nixos.mount"
        "x-gvfs-hide"
      ];
    };
}

# vim: set et ts=2 sw=2 ft=nix :
