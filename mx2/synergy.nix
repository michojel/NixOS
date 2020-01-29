{ config, lib, pkgs, ... }:

{
  services.synergy.server = {
    enable = true;
    configFile = /etc/nixos/synergy-server.conf;
  };

  networking = {
    firewall = {
      allowedTCPPorts = lib.mkAfter [
        24800 # synergy server
      ];
      allowedUDPPorts = lib.mkAfter [
        24800 # synergy server
      ];
    };
  };
}
