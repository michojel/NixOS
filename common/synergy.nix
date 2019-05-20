{ config, lib, pkgs, ... }:

{
	services.synergy.server = {
		enable = true;
    configFile = ./synergy-server.conf;
  };
}
