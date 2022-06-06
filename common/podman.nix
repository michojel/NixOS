{ config, pkgs, lib, nodejs, ... }:

{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      extraPackages = [ pkgs.zfs ];
    };
    # not possible ATM
    #    containers = {
    #      storage = {
    #        driver = "zfs";
    #        runroot = "/var/run/containers/storage";
    #        graphroot = "/var/lib/containers/storage";
    #        options = {
    #          zfs = {
    #            mountopt = "nodev";
    #            fsname = "zdata/local/containers";
    #          };
    #        };
    #      };
    #    };
  };

  environment.systemPackages = with pkgs; [
    buildah
    fuse-overlayfs
  ];

  users.extraUsers.miminar = {
    extraGroups = lib.mkAfter [
      "podman"
    ];
  };

  environment.etc."containers/storage.conf" = lib.mkForce {
    mode = "0644";
    text = ''
      [storage]
      driver = "zfs"
      runroot = "/var/run/containers/storage"
      graphroot = "/var/lib/containers/storage"
      [storage.options]
        [storage.options.zfs]
          mountopt = "nodev"
          fsname = "rpool/local/containers"
    '';
  };
}
