{ config, pkgs, ... }:

{
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    enableOnBoot = true;
    storageDriver = "overlay2";
  };

  environment.systemPackages = with pkgs; [
    buildah
    docker-distribution
    podman
    skopeo

    # podman dependencies
    runc conmon slirp4netns fuse-overlayfs 
  ];

  users.users.miminar = {
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };

  environment.etc."containers/policy.json" = {
    mode="0644";
    text=''
      {
        "default": [
          {
            "type": "insecureAcceptAnything"
          }
        ],
        "transports":
          {
            "docker-daemon":
              {
                "": [{"type":"insecureAcceptAnything"}]
              }
          }
      }
    '';
  };

  environment.etc."containers/registries.conf" = {
    mode="0644";
    text=''
      [registries.search]
      registries = ['quay.io', 'registry.access.redhat.com', 'registry.redhat.io', 'docker.io']
    '';
  };
}
