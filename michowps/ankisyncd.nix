{ config, lib, pkgs, ... }:

let
  uid = 62384;
  port = 27701;
in

{
  services.nginx.virtualHosts = {
    "anki.michojel.cz" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        extraConfig = ''
          client_max_body_size 222M;
        '';
      };
    };
  };

  users.extraUsers.ankisyncd = {
    inherit uid;
    isNormalUser = false;
    isSystemUser = true;
    group = "ankisyncd";
  };

  users.extraGroups.ankisyncd = {
    gid = uid;
  };

  systemd.services.docker-ankisyncd =
    let
      cname = "ankisyncd";
      image = "docker.io/michojel/anki-sync-server:latest";
      dataRoot = "/srv/ankisyncd";
      authDBPath = "${dataRoot}/auth.db";
      sessionDBPath = "${dataRoot}/session.db";

      ankiConf = pkgs.writeTextFile {
        name = "ankisyncd.conf";
        text = ''
          [sync_app]
          host = 127.0.0.1
          port = ${toString port}
          data_root = ${dataRoot}
          base_url = /sync/
          base_media_url = /msync/
          auth_db_path = ${authDBPath}
          # optional, for session persistence between restarts
          session_db_path = ${sessionDBPath}
        '';
      };
    in
    {
      description = "Anki Sync Server";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "default.target" ];
      preStart = ''
        ${pkgs.docker}/bin/docker stop ${cname} 2>/dev/null ||:
        ${pkgs.docker}/bin/docker rm   ${cname} 2>/dev/null ||:
        ${pkgs.docker}/bin/docker pull ${image}
      '';
      preStop = ''
        ${pkgs.docker}/bin/docker stop ${cname} ||:
      '';
      script = ''
        # TODO: fix protobof issues instead of using python implementation
        # TODO: set PYTHONPATH on the image
        ${pkgs.docker}/bin/docker run -u ${toString uid}:${toString uid} --rm --name ${cname} \
            -v /var/lib/private/ankisyncd:${dataRoot}:rw \
            -v ${ankiConf}:/opt/ankisyncd/ankisyncd.conf:ro \
            -e PYTHONPATH=/opt/ankisyncd \
            -e PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python \
            -e ANKISYNCD_SESSION_DB_PATH=${sessionDBPath} \
            -e ANKISYNCD_AUTH_DB_PATH=${authDBPath} \
            -p ${toString port}:${toString port} \
            ${image}
      '';

      serviceConfig = {
        TimeoutStartSec = 30;
        Restart = "always";
      };
    };
}
