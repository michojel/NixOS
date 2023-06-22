{ config, lig, options, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bindfs
  ];

  fileSystems."/home/${config.local.username}/wsp/nixos" =
    {
      device = "/mnt/nixos";
      noCheck = true;
      fsType = "fuse.bindfs";
      options = [
        "nofail"
        "map=root/michojel:@root/@users"
        "x-gvfs-hide"
      ];
    };

  fileSystems."/home/${config.local.username}/.config/nixpkgs" =
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

  fileSystems."/home/${config.local.username}/.config/home-manager" =
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
