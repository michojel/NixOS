{ config, pkgs, ... }:

{
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    enableOnBoot = true;
    storageDriver = "zfs";
  };

  environment.systemPackages = with pkgs; [
    docker-distribution
  ];

  users.users.miminar = {
    extraGroups = pkgs.lib.mkAfter [ "docker" ];
  };
}
