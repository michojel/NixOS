{ config, ... }:

{
  fileSystems."/mnt/ssh/miminarnb" = {
    device = "root@miminarnb:/";
    fsType = "fuse.sshfs";
    noCheck = true;
    options = [
      "allow_other"
      "default_permissions"
      "gid=1000"
      "IdentityFile=/root/.ssh/id_rsa"
      "idmap=user"
      "noauto"
      "nofail"
      "reconnect"
      "rw"
      "uid=1000"
      "x-systemd.automount"
      "x-systemd.requires=network.target"
      "x-systemd.idle-timeout=1min"
      "x-systemd.device-timeout=1s"
      "x-systemd.mount-timeout=1s"
    ];
  };

  fileSystems."/mnt/ssh/miminar@miminarnb" = {
    device = "miminar@miminarnb:/home/miminar";
    fsType = "fuse.sshfs";
    noCheck = true;
    options = [
      "allow_other"
      "default_permissions"
      "gid=1000"
      "IdentityFile=/root/.ssh/id_rsa"
      "idmap=user"
      "noauto"
      "nofail"
      "reconnect"
      "rw"
      "uid=1000"
      "x-systemd.automount"
      "x-systemd.requires=network.target"
      "x-systemd.idle-timeout=1min"
      "x-systemd.device-timeout=1s"
      "x-systemd.mount-timeout=1s"
    ];
  };

  fileSystems."/mnt/ssh/mx2" = {
    device = "root@mx2:/";
    fsType = "fuse.sshfs";
    noCheck = true;
    options = [
      "allow_other"
      "default_permissions"
      "gid=1000"
      "IdentityFile=/root/.ssh/id_rsa"
      "idmap=user"
      "noauto"
      "nofail"
      "reconnect"
      "rw"
      "uid=1000"
      "x-systemd.automount"
      "x-systemd.requires=network.target"
      "x-systemd.idle-timeout=1min"
      "x-systemd.device-timeout=1s"
      "x-systemd.mount-timeout=1s"
    ];
  };

  fileSystems."/mnt/ssh/miminar@mx2" = {
    device = "miminar@mx2:/home/miminar";
    fsType = "fuse.sshfs";
    noCheck = true;
    options = [
      "allow_other"
      "default_permissions"
      "gid=1000"
      "IdentityFile=/root/.ssh/id_rsa"
      "idmap=user"
      "noauto"
      "nofail"
      "reconnect"
      "rw"
      "uid=1000"
      "x-systemd.automount"
      "x-systemd.requires=network.target"
      "x-systemd.idle-timeout=1min"
      "x-systemd.device-timeout=1s"
      "x-systemd.mount-timeout=1s"
    ];
  };
}
