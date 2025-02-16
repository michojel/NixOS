{ config, lib, pkgs, ... }:

let
  userGroupName = "grist";
  uid = 62377;
  port = 28484;
  persistPath = "/var/lib/private/grist";
in
{
  services.nginx.virtualHosts = {
    "grist.michojel.cz" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        #        extraConfig = ''
        #          client_max_body_size 222M;
        #        '';
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

          # WebSocket support
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          #proxy_set_header Connection "upgrade";
          proxy_set_header Connection $http_connection;
        '';
      };
    };
  };

  systemd.services.grist-server =
    let
      cname = "grist-core";
      tag = "1.4.0";
      image = "docker.io/gristlabs/grist:${tag}";
    in
    {
      description = "Evolution of spreadsheets";
      after = [ "docker.service" "authentik.service" ];
      requires = [ "docker.service" "authentik.service" ];
      wantedBy = [ "default.target" ];
      preStart = ''
        ${pkgs.docker}/bin/docker stop ${cname} 2>/dev/null ||:
        ${pkgs.docker}/bin/docker rm   ${cname} 2>/dev/null ||:
        ${pkgs.docker}/bin/docker pull ${image}
        mkdir -p -m 0750 ${persistPath} ||:
        chown "${toString uid}:${toString uid}" "${persistPath}" ||:
      '';
      preStop = ''
        ${pkgs.docker}/bin/docker stop ${cname} ||:
      '';
      script = ''
        ${pkgs.docker}/bin/docker run -u ${toString uid}:${toString uid} --rm --name ${cname} \
            --env=PORT=${toString port} \
            --env-file=${persistPath}/.env \
            --mount=type=bind,source=${persistPath},target=/persist \
            --publish=${toString port}:${toString port} \
            ${image}
      '';

      serviceConfig = {
        TimeoutStartSec = 240;
        Restart = "always";
      };
    };

  users.extraUsers."${userGroupName}" = {
    inherit uid;
    isNormalUser = false;
    isSystemUser = true;
    group = "${userGroupName}";
  };

  users.extraGroups."${userGroupName}" = {
    gid = uid;
  };

  users.users."${config.local.username}" = {
    extraGroups = pkgs.lib.mkAfter [ "${userGroupName}" ];
  };
}
