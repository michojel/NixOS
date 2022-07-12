{ config, lib, pkgs, ... }:

{
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
