{ config, pkgs, nodejs, ... }:
let
  gping = "${config.security.wrapperDir}/ping -c 1 -w 2 -W 2 google.com";

  wait-online = pkgs.writeTextFile {
    name = "wait-online.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      ${pkgs.networkmanager}/bin/nmcli --terse monitor | grep '^Connectivity is now' | while read -r line; do
        grep -q -F full <<<"''${line}" && ${gping} && exit 0
      done &
      function cleanup() {
        kill -9 %1 >/dev/null 2>&1
      }
      trap cleanup EXIT 
      if [[ -n "$(${pkgs.networkmanager}/bin/nmcli --terse connection show --active | grep -v docker0)" ]]; then
        if ${gping}; then
          exit 0
        fi
      fi
    '';
  };
  wait-offline = pkgs.writeTextFile {
    name = "wait-offline.sh";
    executable = true;
    text = ''
       #!${pkgs.bash}/bin/bash
       set -euo pipefail
       IFS=$'\n\t'
       CHECK_INTERVAL="''${CHECK_INTERVAL:-11}"
       ${pkgs.networkmanager}/bin/nmcli --terse monitor | grep '^Connectivity is now' | while read -r line; do
         # terminate if the connectivity is not full
         if ! grep -q -F full <<<"''${line}"; then
           printf '%s\n' "$line"
      exit 1
         fi
       done &
       function cleanup() {
         kill -9 %1 >/dev/null 2>&1
       }
       trap cleanup EXIT 
       if [[ -z "$(${pkgs.networkmanager}/bin/nmcli --terse connection show --active | grep -v docker0)" ]]; then
         printf 'No active connection!\n'
         exit 1
       fi
       while true; do
         if ! ${gping}; then
           printf '%s\n' "Failed to ping google.com. Terminating ..."
           exit 1
         fi
         sleep "''${CHECK_INTERVAL}"
       done
    '';
  };
in
rec {
  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "19:15";
      # Options given to nix-collect-garbage when the garbage collector is run automatically. 
      options = "--delete-older-than 21d";
    };
  };

  boot = {
    cleanTmpDir = true;
    loader.timeout = 2;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  # set temporarily to older release to work-around issue with systemd-timesyncd
  # - https://github.com/NixOS/nixpkgs/issues/64922
  system.stateVersion = "20.09";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-20.09";
  system.autoUpgrade.allowReboot = false;
  system.autoUpgrade.dates = "01:00";

  time.timeZone = "Europe/Prague";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  services = {
    logind = {
      lidSwitchExternalPower = "lock";
    };
    openssh = {
      enable = true;
      forwardX11 = true;
    };

    udev.extraRules =
      ''
        ACTION=="add", KERNEL=="i2c-[0-9]*", GROUP="i2c"
      '';
    irqbalance.enable = true;
  };

  programs = {
    browserpass.enable = true;
  };

  systemd = {
    tmpfiles.rules = [ "d /tmp 1777 root root 11d" ];
    services.nixos-upgrade = {
      preStart = ''
        set -euo pipefail
        ${pkgs.sudo}/bin/sudo -u miminar "${pkgs.bash}/bin/bash" \
          -c 'cd /home/miminar/wsp/nixos && git pull https://github.com/michojel/NixOS master'
        ${pkgs.nix}/bin/nix-channel --update nixos-unstable
      '';
      postStart = ''
        ${pkgs.sudo}/bin/sudo -u miminar "${pkgs.bash}/bin/bash" \
          -c 'cd $HOME && nix-env --upgrade "*"
            nix-env -iA nixos.chromium-wrappers nixos.w3'
        # remove when https://github.com/NixOS/nixpkgs/pull/86489 is available
      '';
      requires = pkgs.lib.mkAfter [ "network-online.target" ];
      after = pkgs.lib.mkAfter [ "network-online.target" ];
    };

    services.systemd-rfkill = {
      wantedBy = [ "default.target" ];
    };

    user.targets.online = {
      description = "The localhost is online target";
      requires = [ "online.service" ];
      after = [ "online.service" ];
      wantedBy = [ "default.target" ];
    };

    user.services.online = {
      description = "Run until the connection to the internet is lost";
      preStart = "${wait-online}";
      partOf = [ "online.target" ];
      script = "${wait-offline}";
      restartIfChanged = true;
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "500ms";
      };
    };
  };

  documentation = {
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
    nixos.includeAllModules = true;
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  # causes hangs
  #powerManagement.powertop.enable = true;

  environment.extraOutputsToInstall = [ "doc" "info" "devdoc" "man" ];
}
