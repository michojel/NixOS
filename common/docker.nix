{ config, lib, pkgs, ... }:

let
  cfg = config.profile;
in
{
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    enableOnBoot = true;
    storageDriver = lib.mkDefault "zfs";
    # due to "http: invalid Host header" issues
  };

  environment.systemPackages = with pkgs; [
    docker-distribution
  ];

  users.users."${config.local.username}" = {
    extraGroups = pkgs.lib.optional (!cfg.server.enable) (pkgs.lib.mkAfter [ "docker" ]);
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
    "172.17.0.1" = [ "host.docker.internal" "proxy.docker.internal" ];
  };
}

