{ config, ... }:

{
  environment.etc = {
    "crypttab" = {
      enable = true;
      text = ''
        # <name>        <device>                                        <password>                      <options>
        luks-extdata    UUID=3c9dda76-333e-4d46-884f-2f90f88e09c0       /etc/luks/extdata-keyfile       luks,key-slot=1,nofail,noauto,x-systemd.device-timeout=10s
      '';
    };
  };

  fileSystems."/mnt/extdata" = {
      device = "/dev/mapper/luks-extdata";
      fsType = "ext4";
      noCheck = true;
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-uuid/3c9dda76-333e-4d46-884f-2f90f88e09c0";
        keyFile = "/etc/luks/extdata-keyfile";
        label = "luks-extdata";
      };
      options = [
        "defaults" "rw"
        "group" "user" "uid=1000"
        "noatime" "noauto" "nodev" "noexec" "nofail" "nosuid"
        "x-systemd.automount"
        "x-systemd.device-timeout=10s"
        "x-systemd.idle-timeout=1min"
        "x-systemd.mount-timeout=10s"
      ];
    };
}
