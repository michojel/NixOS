{ config, lib, pkgs, ... }:

{
  services.nginx.virtualHosts = {
    "gitlab.michojel.cz" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
        extraConfig = ''
          client_max_body_size 4G;
          proxy_request_buffering off;
        '';
      };
    };
  };

  services.gitlab = {
    enable = true;
    databasePasswordFile = "/var/keys/gitlab/db_password";
    initialRootPasswordFile = "/var/keys/gitlab/root_password";
    initialRootEmail = "mm@michojel.cz";
    https = true;
    host = "gitlab.michojel.cz";
    port = 443;
    user = "git";
    group = "git";
    databaseUsername = "git";
    smtp = {
      enable = true;
      address = "localhost";
      port = 25;
    };
    secrets = {
      dbFile = "/var/keys/gitlab/db";
      secretFile = "/var/keys/gitlab/secret";
      otpFile = "/var/keys/gitlab/otp";
      jwsFile = "/var/keys/gitlab/jws";
      activeRecordPrimaryKeyFile = "/var/keys/gitlab/activeRecordPrimaryKeyFile";
      activeRecordDeterministicKeyFile = "/var/keys/gitlab/activeRecordDeterministicKeyFile";
      activeRecordSaltFile = "/var/keys/gitlab/activeRecordSaltFile";
    };
    extraConfig = {
      gitlab = {
        email_from = "gitlab-no-reply@michojel.cz";
        email_display_name = "Michojel's GitLab";
        email_reply_to = "gitlab-no-reply@michojel.cz";
        default_projects_features = { builds = false; };
      };
    };
    backup = {
      startAt = "03:00";
      keepTime = 48;
    };
  };
}
