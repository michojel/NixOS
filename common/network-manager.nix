{ config, lib, pkgs, ... }:

{
  environment.etc = {
    "NetworkManager/dnsmasq.d/hosts" = {
      # used in a dispatcher script to store files with hosts settings
      source = pkgs.writeText "nm-dnsmasq-hosts-conf" ''
        hostsdir=/etc/hosts.d
      '';
      mode   = "0444";
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
      dynamicHosts.enable = true;
      extraConfig = ''
        [logging]
        level = DEBUG
        domains = ALL
      '';
      dispatcherScripts = with pkgs; [
        {
          source = let
              rawfile = builtins.readFile "/mnt/nixos/common/nm-dispatchers/hosts.sh";
            in 
              writeText "nm-dispatcher-hosts.sh" (
                lib.replaceStrings
                  [ "#!/usr/bin/env bash" "@net-tools@"]
                  ["#!${bash}/bin/bash" "${nettools}"]
                  rawfile
              );
        }
      ];
    };
  };
}
