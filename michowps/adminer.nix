{ config, lib, pkgs, ... }:

{
  services.phpfpm.pools = {
    "adminer" = {
      user = "wordpress";
      group = config.services.nginx.group;
      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 16;
        "pm.start_servers" = 1;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 2;
        "pm.max_requests" = 500;
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
      };
    };
  };

  services.nginx.virtualHosts = {
    "adminer.michojel.cz" = {
      enableACME = true;
      forceSSL = true;
      root = "${pkgs.adminer}";
      extraConfig = ''
        index  adminer.php index.php index.html index.htm;
      '';
      locations."/".tryFiles = "$uri $uri/ /adminer.php?$args";
      locations."~ [^/]\\.php(/|$)".extraConfig = ''
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        if (!-f $document_root$fastcgi_script_name) {
            return 404;
        }

        # include the fastcgi_param setting
        fastcgi_pass     unix:${config.services.phpfpm.pools."adminer".socket};
        fastcgi_index adminer.php;
        # Mitigate https://httpoxy.org/ vulnerabilities
        fastcgi_param HTTP_PROXY "";
        fastcgi_param    SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include ${pkgs.nginx}/conf/fastcgi_params;
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    adminer
  ];
}
