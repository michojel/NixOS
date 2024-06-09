{ config, lib, pkgs, ... }:

let
  luksDevs = {
    "extdata" = { blkDevUUID = "3c9dda76-333e-4d46-884f-2f90f88e09c0"; };
    "kstonvme1tb" = { blkDevUUID = "793abdae-1224-49bd-84de-ee7ad1ee088b"; };
    "seagatehdd1tb" = { blkDevUUID = "aa4a2bc2-2a08-4b52-a05e-d10810292190"; };
  };

in
{
  services = {
    udev =
      let
        mkRule = as: lib.concatStringsSep ", " as;
        mkRules = rs: lib.concatStringsSep "\n" rs;
      in
      {
        extraRules = mkRules (
          [
            # allow power savings for rotational drives; turn off the motor after 205 = 41*5 seconds
            (
              mkRule [
                ''ACTION=="add|change"''
                ''SUBSYSTEM=="block"''
                ''KERNEL=="sd[a-z]"''
                ''ATTR{queue/rotational}=="1"''
                ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S 41 /dev/%k"''
              ]
            )

            # the following disks do not support APM (Advanced Power Management)
          ] ++ (
            map
              (
                { vendor, product }: mkRule [
                  ''ACTION=="add|change"''
                  ''SUBSYSTEM=="block"''
                  ''KERNEL=="sd[a-z]"''
                  ''ATTR{idVendor}=="${vendor}"''
                  ''ATTR{idProduct}=="${product}"''
                  ''RUN+="${pkgs.hd-idle}/bin/hd-idle -a /dev/%k -i 205"''
                ]
              ) [
              # extdata
              { vendor = "174c"; product = "1153"; }
              # small Seagate 2TiB disk
              { vendor = "0bc2"; product = "ab26"; }
            ]
          )
        );
      };
  };


  fileSystems = (lib.foldl'
    (acc: name: acc // {
      "/mnt/${name}" = {
        device = "/dev/mapper/${name}";
        noCheck = true;
        encrypted = {
          blkDev = ("UUID=" + luksDevs."${name}".blkDevUUID);
          enable = true;
          keyFile = "/mnt/nixos/secrets/luks/${name}";
          label = "${name}";
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
    })
    { }
    (lib.attrNames luksDevs)) // {

    "/mnt/gpgflashj" = {
      device = "/dev/mapper/gpgflashj";
      fsType = "ext4";
      noCheck = true;
      #          encrypted = {
      #            enable = true;
      #            blkDev = "UUID=f0936982-39a5-4192-96c1-380dfc5ec2ff";
      #            label = "gpgflashj";
      #          };
      options = [
        "defaults"
        "rw"
        "group"
        "user"
        "uid=1000"
        "noatime"
        "noauto"
        "nodev"
        "noexec"
        "nofail"
        "nosuid"
        "owner"
        "x-systemd.automount"
        "x-systemd.device-timeout=2s"
        "x-systemd.idle-timeout=1min"
        "x-systemd.mount-timeout=2s"
      ];
    };
  };

  environment.etc = {
    "crypttab" =
      let
        mkCryptTabEntry = name: uuid: (lib.concatStringsSep " " [
          "${name} UUID=${uuid}"
          "/mnt/nixos/secrets/luks/${name} noauto,nofail,luks,x-systemd.device-timeout=7s"
        ]);
      in
      {
        source = pkgs.writeText "crypttab" (
          lib.concatStringsSep "\n" (lib.concatLists
            [
              (map (name: mkCryptTabEntry name (luksDevs."${name}".blkDevUUID)) (lib.attrNames luksDevs))
              [
                (mkCryptTabEntry "gpgflashj" "f0936982-39a5-4192-96c1-380dfc5ec2ff")
                ""
              ]
            ]
          )
        );
        mode = "0644";
      };
  };

  # TODO: set StopWhenUnneeded=yes on systemd-cryptsetup@extdata.service
}
