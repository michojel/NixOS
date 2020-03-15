{ config
, pkgs
, myHosts ? [ "mx2" "minap50" "mint540" ]
, excludedHosts ? [ config.networking.hostName ]
, ...
}:
let
  userIdentityFile = config.users.extraUsers.miminar.home + "/.ssh/id_rsa_nopw";
  rootIdentityFile = "/root/.ssh/id_rsa_nopw";
  sshRootPath = "/ssh";
  mkMountPoint = { user, host }: sshRootPath + "/" + (if user == "miminar" then "" else user + "-") + host;
  stripDomain = fqdn: builtins.head (pkgs.lib.splitString "." fqdn);
  excludeHostSet = pkgs.lib.foldr (a: b: (b // { a = true; })) {} [ config.networking.hostName ];

  mountPoints = with pkgs.lib; concatMap (
    fqdn: let
      host = stripDomain fqdn;
    in
      [
        {
          user = "miminar";
          host = host
          ;
          fqdn = fqdn;
          path = "/home/miminar";
          identityFile = userIdentityFile;
        }
        {
          user = "root";
          host = host
          ;
          fqdn = fqdn;
          path = "/";
          identityFile = rootIdentityFile;
        }
      ]
  ) (
    pkgs.lib.filter (x: !(excludeHostSet."${stripDomain x}" or false)) [
      "mx2.mihoje.me"
      "minap50.fritz.box"
      "mint540.fritz.box"
    ]
  );
in
{
  systemd.mounts = let
    makeSshMount = { user, host, path, identityFile, fqdn }: {
      enable = true;
      what = user + "@" + fqdn + ":" + path;
      where = mkMountPoint { user = user; host = host; };
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      type = "sshfs";
      options = "allow_other,reconnect,IdentityFile=" + identityFile;
    };
  in
    map makeSshMount mountPoints;

  systemd.automounts = let
    makeSshAutomount = { user, host, ... }: {
      enable = true;
      where = mkMountPoint { user = user; host = host; };
      wantedBy = [ "default.target" "remote-fs.target" ];
      automountConfig = { TimeoutIdleSec = "5min"; };
    };
  in
    map makeSshAutomount mountPoints;

  environment.systemPackages = with pkgs; [
    sshfs
  ];
}
