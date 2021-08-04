{ config, pkgs, lib, nodejs, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
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

  environment.etc."containers/registries.conf" = {
    mode = "0644";
    text = ''
      [registries.search]
      registries = ['docker.io', 'quay.io']
    '';
  };

  environment.etc."containers/storage.conf" = {
    mode = "0644";
    text = ''
      [storage]
      driver = "zfs"
      runroot = "/var/run/containers/storage"
      graphroot = "/var/lib/containers/storage"
      [storage.options]
        [storage.options.zfs]
          mountopt = "nodev"
          fsname = "zdata/local/containers"
    '';
  };
}
