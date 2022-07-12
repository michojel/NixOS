{ config, lib, pkgs, ... }:

{
  services.nginx.virtualHosts = {
    "anki.michojel.cz" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:27701";
    };
  };

  systemd.services.docker-ankisyncd =
    let
      cname = "ankisyncd";
      image = "docker.io/michojel/anki-sync-server:latest";
      port = "27701";
      dataRoot = "/srv/ankisyncd";
      authDBPath = "${dataRoot}/auth.db";
      sessionDBPath = "${dataRoot}/session.db";

      ankiConf = pkgs.writeTextFile {
        name = "ankisyncd.conf";
        text = ''
          [sync_app]
          # change to 127.0.0.1 if you don't want the server to be accessible from the internet
          host = 0.0.0.0
          port = ${port}
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
        ${pkgs.docker}/bin/docker run -u 62384:62384 --rm --name ${cname} \
            -v /var/lib/private/ankisyncd:${dataRoot}:rw \
            -v ${ankiConf}:/opt/ankisyncd/ankisyncd.conf:ro \
            -e PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python \
            -e ANKISYNCD_SESSION_DB_PATH=${sessionDBPath} \
            -p ${port}:${port} \
            ${image}
      '';

      serviceConfig = {
        TimeoutStartSec = 5;
        Restart = "always";
      };
    };
}
