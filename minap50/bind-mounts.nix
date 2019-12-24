{ config, ... }:

{
  fileSystems."/etc/nixos" =
    { device = "/mnt/nixos/minap50";
      noCheck = true;
      options = [
        "bind"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-nixos.mount"
        "x-systemd.after=mnt-nixos.mount"
        "x-gvfs-hide"
      ]; 
    };

  fileSystems."/home/miminar/wsp/nixos" =
    { device = "/mnt/nixos";
      noCheck = true;
      fsType = "fuse.bindfs";
      options = [
        "nofail"
        "map=root/miminar:@root/@users"
        "x-gvfs-hide"
      ];
    };

  fileSystems."/home/miminar/.config/nixpkgs" =
    { device  = "/mnt/nixos/user";
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

# ex: et ts=2 sw=2 ft=nix :
