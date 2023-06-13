{ config, lib, pkgs, ... }:

{
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    enableOnBoot = true;
    storageDriver = lib.mkDefault "zfs";
  };

  environment.systemPackages = with pkgs; [
    docker-distribution
  ];

  users.users."${config.local.username}" = {
    extraGroups = pkgs.lib.mkAfter [ "docker" ];
  };

  environment.etc."docker/daemon.json" = {
    text = ''
      {
        "features": {
          "buildkit" : true
        }
      }
    '';
  };

  networking.hosts = {
    "172.17.0.1" = [ "proxy.docker.internal" ];
  };
}

