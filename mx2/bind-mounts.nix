{ config, ... }:

{
  fileSystems."/etc/nixos" =
    { device = "/mnt/nixos/mx2";
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
    { device  = "/mnt/nixos/user/miminar/nixpkgs";
      options = [ "bind" ];
    };
}

# vim: set et ts=2 sw=2 ft=nix :
