{ config, lib, pkgs, ... }:

let
  encryptedPoolName = "encbig";

  zfs-load-key = pkgs.writeTextFile {
    name = "zfs-load-key.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      readonly ATTEMPTS=3
      POOLNAME="''${1:-${encryptedPoolName}}"

      if ! ${pkgs.zfsUnstable}/bin/zpool list -H -o load_guid "''${POOLNAME}" >/dev/null 2>&1; then
        ${pkgs.zfsUnstable}/bin/zpool import -d "/dev/disk/by-id" -N "''${POOLNAME}" || :
      fi
      ${pkgs.zfsUnstable}/bin/zfs list -H -o keystatus "''${POOLNAME}" |& grep -q "^available" && exit 0
      for ((i=0; i < ''${ATTEMPTS}; i++)); do
        ${pkgs.systemd}/bin/systemd-ask-password "Password for ''${POOLNAME} encrypted storage: " | \
          ${pkgs.zfsUnstable}/bin/zfs load-key "''${POOLNAME}" && exit 0
      done
      exit 1
    '';
  };

in {
  boot = {
    zfs = {
      enableUnstable               = true;
      requestEncryptionCredentials = true;
    };
    supportedFilesystems = ["zfs"];
  };

  services = {
    zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
  };

  systemd = {
    services = {
      zfs-import-encdedup.unitConfig.RequiresMountsFor = "/mnt/nixos/secrets/luks/encdedup";
      zfs-import-encuncomp.unitConfig.RequiresMountsFor = "/mnt/nixos/secrets/luks/encuncomp";
      "zfs-key-${encryptedPoolName}" = {
        wantedBy = ["zfs.target"];
        after = config.systemd.services."zfs-import-${encryptedPoolName}".after;
        before = ["zfs-import-${encryptedPoolName}.service" "zfs-mount.service" "systemd-user-sessions.service"];
        description = "Load storage encryption keys";
        unitConfig = {
          DefaultDependencies = "no";
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
          ExecStart = "${zfs-load-key} ${encryptedPoolName}";
        };
      };
    };
  };
}
