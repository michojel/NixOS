{ config, lib, pkgs, ... }:

let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

in {
  services = {
    udev = let
      mkRule  = as: lib.concatStringsSep ", " as;
      mkRules = rs: lib.concatStringsSep "\n" rs;
    in {
      extraRules = mkRules ([
        # allow power savings for rotational drives; turn off the motor after 205 = 41*5 seconds
        (mkRule [''ACTION=="add|change"''
                 ''SUBSYSTEM=="block"''
                 ''KERNEL=="sd[a-z]"''
                 ''ATTR{queue/rotational}=="1"''
                 ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 41 /dev/%k"''
        ])

      # the following disks do not support APM (Advanced Power Management)
      ] ++ (map ({vendor, product}: mkRule [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''KERNEL=="sd[a-z]"''
        ''ATTR{idVendor}=="${vendor}"''
        ''ATTR{idProduct}=="${product}"''
        ''RUN+="${pkgs.hd-idle}/bin/hd-idle -a /dev/%k -i 205"''
      ]) [
        # extdata
        {vendor = "174c"; product = "1153"; }
        # small Seagate 2TiB disk
        {vendor = "0bc2"; product = "ab26"; }
      ]));
    };
  };

  fileSystems."/mnt/extdata" =
    { device = "/dev/mapper/extdata";
      noCheck = true;
      encrypted = {
        blkDev = "UUID=3c9dda76-333e-4d46-884f-2f90f88e09c0";
        enable = true;
        keyFile = "/mnt/nixos/secrets/luks/extdata";
        label = "extdata";
      };
      options = [
        "relatime"
        "noauto"
        "nofail"
        "x-systemd.automount"
        "x-systemd.requires=mnt-nixos.mount"
        "x-systemd.after=mnt-nixos.mount"
        "x-systemd.idle-timeout=5min"
      ];
    };

  environment.etc = {
    "crypttab" = {
      source = pkgs.writeText "crypttab" (lib.concatStringsSep " " [
        "extdata UUID=3c9dda76-333e-4d46-884f-2f90f88e09c0"
        "/mnt/nixos/secrets/luks/extdata noauto,nofail,luks"
      ]);
      mode   = "0644";
    };
  };

  # TODO: set StopWhenUnneeded=yes on systemd-cryptsetup@extdata.service
}
