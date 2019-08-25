{ config, pkgs
, myHosts ? ["mx2" "minap50" "mint540"]
, excludedHosts ? [config.networking.hostName]
, ... }:
let
  userIdentityFile = config.users.extraUsers.miminar.home + "/.ssh/id_rsa_nopw";
  rootIdentityFile = "/root/.ssh/id_rsa_nopw";
  sshRootPath  = "/ssh";
  mkMountPoint = { user, host }: sshRootPath + "/" +
    (if user == "miminar" then "" else user + "-") + host;
  excludeHostSet = pkgs.lib.foldr (a: b: (b // {a = true;})) {} [config.networking.hostName];

  mountPoints = pkgs.lib.concatMap (h: [
      { user = "miminar"; host = h;   path = "/home/miminar"; identityFile = userIdentityFile; }
      { user = "root";    host = h;   path = "/";             identityFile = rootIdentityFile; }
    ]) (pkgs.lib.filter (x: !(excludeHostSet."${x}" or false)) ["mx2" "minap50" "mint540"]);
in {
  systemd.mounts = let
    makeSshMount = { user, host, path, identityFile }: {
        enable   = true;
        what     = user + "@" + host + ":" + path;
        where    = mkMountPoint { user = user; host = host; };
        after    = ["network-online.target"];
        requires = ["network-online.target"];
        type     = "sshfs";
        options  = "allow_other,reconnect,IdentityFile=" + identityFile;
      };
  in map makeSshMount mountPoints;

  systemd.automounts = let
    makeSshAutomount = { user, host, ... }: {
        enable          = true;
        where           = mkMountPoint { user = user; host = host; };
        wantedBy        = ["default.target" "remote-fs.target"];
        automountConfig = { TimeoutIdleSec = "5min"; };
      };
  in map makeSshAutomount mountPoints;

  environment.systemPackages = with pkgs; [
    sshfs
  ];
}
