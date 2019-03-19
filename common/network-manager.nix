{ config, lib, pkgs, ... }:

let
  dnsmasq-update-nameservers = with pkgs; writeTextFile {
    name = "dnsmasq-update-nameservers.sh";
    executable = true;
    text = lib.replaceStrings
      [ "#!/usr/bin/env bash" "@net-tools@"
        "dbus-send" "nmcli"
        "sudo" "ipcalc"
      ]
      [ "#!${bash}/bin/bash" "${nettools}"
        "${dbus}/bin/dbus-send" "${networkmanager}/bin/nmcli"
        "${sudo}/bin/sudo" "${ipcalc}/bin/ipcalc"
      ]
      (builtins.readFile "/mnt/nixos/common/dnsmasq-update-nameservers.sh");
  };
in {
  environment.etc = {
    # TODO: fix this
    "NetworkManager/dnsmasq.d/hosts" = {
      # used in a dispatcher script to store files with hosts settings
      source = pkgs.writeText "nm-dnsmasq-hosts-conf" ''
        hostsdir=/etc/hosts.d
      '';
      mode   = "0444";
    };
    # TODO: fix this
    "NetworkManager/dnsmasq.d/general" = {
      mode   = "0444";
      source = pkgs.writeText "nm-dnsmasq-general-conf" ''
        log-queries
        log-dhcp
      '';
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      dns = "none";
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

        {
          source = writeText "nm-dispatcher-dnsmasq.sh" ''
                #!${bash}/bin/bash

                set -euo pipefail

                "${dnsmasq-update-nameservers}" | \
                    systemd-cat -t "network-manager-dispatcher-dnsmasq"
              '';
        }
      ];
    };
  };

  services.dnsmasq = {
    # TODO: make sure /etc/hosts.d and /etc/dnsmasq.d directories exit in the .service
    alwaysKeepRunning = false;
    enable = true;
    extraConfig = ''
      log-queries
      bind-interfaces
      all-servers
      no-negcache
      hostsdir=/etc/hosts.d
      conf-dir=/etc/dnsmasq.d/,*.conf
      servers-file=/etc/dnsmasq-servers.conf
    '';
  };
}
