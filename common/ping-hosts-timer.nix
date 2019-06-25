{ config, lib, pkgs, ... }:

let 
  ping-hosts = pkgs.writeTextFile {
    name = "ping-hosts.sh";
    executable = true;
    text = ''
      #!/usr/bin/env bash

      set -euo pipefail
      IFS=$'\n\t'

      readonly hostsFile="''${HOME}/.ssh/hosts-to-ping"
      readonly sshPubKey="''${HOME}/.ssh/id_rsa_nopw"

      if [[ ! -e "''${sshPubKey}" ]]; then
        printf 'The SSH public key %s does not exist!\n' >&2 "''${sshPubKey}"
        exit 1
      fi

      hosts=( )

      if [[ $# -gt 0 ]]; then
        hosts=( "$@" )
      else
        while IFS=  read -r line; do
          if [[ "''${line## *}" =~ ^([^#][[:alnum:]_.-]+) ]]; then
            hosts+=( "''${BASH_REMATCH[1]}" )
          fi
        done < <(cat "$hostsFile")
      fi
      if [[ "''${#hosts[@]}" -lt 1 ]]; then
        exit 0
      fi

      for h in "''${hosts[@]}"; do
        printf "Pinging %s...\n" "$h"
        ssh -i "$sshPubKey" -o "StrictHostKeyChecking=no" "$h" echo pong ||:
      done
    '';
  };
in {
  systemd.user.services.ping-hosts = {
    description     = "SSH into hosts listed in $HOME/.ssh/hosts-to-ping";
    # TODO: depend on network-online.target
    reloadIfChanged = true;
    environment     = {
      SSH_ASKPASS   = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
    };
    path            = [ pkgs.bash pkgs.openssh pkgs.x11_ssh_askpass ];
    serviceConfig   = {
      Type          = "oneshot";
      ExecStart     = "${ping-hosts}";
    };
  };

  systemd.user.timers.ping-hosts = {
    description     = "Periodically SSH into hosts listed in $HOME/.ssh/hosts-to-ping";
    wantedBy        = ["timers.target" "default.target"];
    timerConfig     = {
      Unit          = "ping-hosts.service";
      OnCalendar     = "03:15";
    };
  };
}
