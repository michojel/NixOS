
  systemd.user.services.imapfilter = {
    enable = true;
    description = "Imap filter";
    after = ["network.target"];
    serviceConfig = {
      Type       = "simple";
      ExecStart  = "${pkgs.imapfilter}/bin/imapfilter -c %h/.config/imapfilter/config.lua";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      KillMode   = "process";
      Restart    = "always";
    };
  };

  
