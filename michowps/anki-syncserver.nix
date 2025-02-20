{ config, lib, pkgs, ... }:

let
  uid = 62384;
  port = 27702;
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

  systemd.services.docker-anki-syncserver =
    let
      cname = "anki-syncserver";
      tag = "v25.07.2";
      image = "registry.gitlab.com/michojel/anki-server:${tag}";
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
        ${pkgs.docker}/bin/docker run -u ${toString uid}:${toString uid} --rm --name ${cname} \
            --mount=type=bind,source=/var/lib/private/anki/syncserver,target=/var/lib/anki/syncserver \
            --mount=type=bind,readonly,source=/var/lib/private/anki/syncusers,target=/var/lib/anki/syncusers \
            -e SYNC_HOST=0.0.0.0 \
            -p ${toString port}:80 \
            ${image}
      '';

      serviceConfig = {
        TimeoutStartSec = 30;
        Restart = "always";
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

  users.users."${config.local.username}" = {
    extraGroups = pkgs.lib.mkAfter [ "ankisyncd" ];
  };

}
