{ config, ... }:

{
  fileSystems."/etc/nixos" =
    { device = "/mnt/nixos/mint540";
      noCheck = true;
      options = [
        "bind"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-nixos.mount"
        "x-systemd.after=mnt-nixos.mount"
      ]; 
    };

  fileSystems."/home/miminar/wsp/nixos" =
    { device = "/mnt/nixos";
      noCheck = true;
      fsType = "fuse.bindfs";
      options = [
        "nofail"
        "map=root/miminar:@root/@users"
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
      ];
    };
}

# vim: set et ts=2 sw=2 ft=nix :