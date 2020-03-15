{ config, lib, pkgs, ... }:

{
  services.synergy.server = {
    enable = true;
    configFile = /etc/nixos/synergy-server.conf;
    screenName = config.networking.hostName;
  };

  networking = {
    firewall = {
      allowedTCPPorts = lib.mkAfter [ 24800 ];
      allowedUDPPorts = lib.mkAfter [ 24800 ];
    };
  };
}
