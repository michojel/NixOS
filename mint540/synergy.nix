{ config, lib, pkgs, ... }:

{
  services.synergy.server = {
    enable = true;
    configFile = ./synergy-server.conf;
  };
}

# ex: set et ts=2 sw=2 :
