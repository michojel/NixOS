{ config, lib, pkgs, ... }:
let
  dnsmasq-update-nameservers = with pkgs; writeTextFile {
    name = "dnsmasq-update-nameservers.sh";
    executable = true;
    text = lib.replaceStrings
      [
        "#!/usr/bin/env bash"
        "@net-tools@"
        "dbus-send"
        "nmcli"
        "sudo"
        "ipcalc"
        "bc"
      ]
      [
        "#!${bash}/bin/bash"
        "${nettools}"
        "${dbus}/bin/dbus-send"
        "${networkmanager}/bin/nmcli"
        "${sudo}/bin/sudo"
        "${ipcalc}/bin/ipcalc"
        "${bc}/bin/bc"
      ]
      (builtins.readFile "/mnt/nixos/common/dnsmasq-update-nameservers.sh");
  };

  dnsmasq-ensure-dir-exists = with pkgs; writeTextFile {
    name = "dnsmasq-ensure-dir-exists.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash

      for path in /etc/dnsmasq.d /etc/dnsmasq-servers.conf /etc/hosts.d; do
        ${pkgs.coreutils}/bin/mkdir $path 2>/dev/null
        ${pkgs.coreutils}/bin/chown dnsmasq:networkmanager $path
        ${pkgs.coreutils}/bin/chmod g+w $path
      done

      # copied from config.systemd.services.dnsmasq.serviceConfig.ExecStartPre
      # TODO: instead of copy&paste, determine the text and execute it
      ${pkgs.coreutils}/bin/mkdir -m 755 -p /var/lib/dnsmasq
      ${pkgs.coreutils}/bin/touch /var/lib/dnsmasq/dnsmasq.leases
      ${pkgs.coreutils}/bin/chown -R dnsmasq /var/lib/dnsmasq
      ${pkgs.coreutils}/bin/touch /etc/dnsmasq-{conf,resolv}.conf
      dnsmasq --test
    '';
  };
in
{
  environment.etc = {
    # TODO: fix this
    "NetworkManager/dnsmasq.d/hosts" = {
      # used in a dispatcher script to store files with hosts settings
      source = pkgs.writeText "nm-dnsmasq-hosts-conf" ''
        hostsdir=/etc/hosts.d
      '';
      mode = "0444";
    };
    # TODO: fix this
    "NetworkManager/dnsmasq.d/general" = {
      mode = "0444";
      source = pkgs.writeText "nm-dnsmasq-general-conf" ''
        #log-queries
        #log-dhcp
      '';
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      dns = "none";
      enableStrongSwan = true;
      dispatcherScripts = with pkgs; [
        {
          source =
            let
              rawfile = builtins.readFile "/mnt/nixos/common/nm-dispatchers/hosts.sh";
            in
            writeText "nm-dispatcher-hosts.sh" (
              lib.replaceStrings
                [ "#!/usr/bin/env bash" "@net-tools@" ]
                [ "#!${bash}/bin/bash" "${nettools}" ]
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

  systemd.services = {
    dnsmasq.serviceConfig.ExecStartPre = lib.mkForce dnsmasq-ensure-dir-exists;
    # only for laptops
    NetworkManager-wait-online.enable = false;
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
