{ config, pkgs, ... }:

let
  identityFile = config.users.extraUsers.miminar.home + "/.ssh/id_rsa_nopw";
  sshRootPath  = "/ssh";
  mkMountPoint = { user, host }: sshRootPath + "/" +
    (if user == "miminar" then "" else user + "-") + host;
in {
  systemd.mounts = let
    makeSshMount = { user, host, path }: {
        enable   = true;
        what     = user + "@" + host + ":" + path;
        where    = mkMountPoint { user = user; host = host; };
        after    = ["network-online.target"];
        requires = ["network-online.target"];
        type     = "sshfs";
        options  = "allow_other,reconnect,IdentityFile=" + identityFile;
      };
  in map makeSshMount [
    { user = "miminar"; host = "miminarnb";    path = "/home/miminar"; }
    { user = "root";    host = "miminarnb";    path = "/"; }
    { user = "miminar"; host = "minap50";    path = "/home/miminar"; }
    { user = "root";    host = "minap50";    path = "/"; }
  ];

  systemd.automounts = let
    makeSshAutomount = { user, host }: {
        enable          = true;
        where           = mkMountPoint { user = user; host = host; };
        wantedBy        = ["default.target" "remote-fs.target"];
        automountConfig = { TimeoutIdleSec = "5min"; };
      };
  in map makeSshAutomount [
    { user = "miminar"; host = "miminarnb"; }
    { user = "root";    host = "miminarnb"; }
    { user = "miminar"; host = "minap50"; }
    { user = "root";    host = "minap50"; }
  ];
}
