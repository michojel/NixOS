{ config, lib, pkgs, ... }:

let
  nixos_22_11 = import <nixos-22.11> { };
in

{
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    enableOnBoot = true;
    storageDriver = lib.mkDefault "zfs";
    # due to "http: invalid Host header" issues
    package = nixos_22_11.docker;
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
    "172.17.0.1" = [ "host.docker.internal" "proxy.docker.internal" ];
  };
}

