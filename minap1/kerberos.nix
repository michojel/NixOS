{ config, pkgs, ... }:

{
  krb5 = {
    enable = true;
    libdefaults = {
      default_realm = "REDHAT.COM";
      ticket_lifetime = "24h";
      dns_lookup_realm = false;
      dns_lookup_kdc = false;
      forwardable = true;
      renew_lifetime = "7d";
      #default_ccache_name = "KEYRING:persistent:%{uid}";
    };

    domain_realm = ''
      .redhat.com             = REDHAT.COM
      redhat.com              = REDHAT.COM
      .fedoraproject.org      = FEDORAPROJECT.ORG
      fedoraproject.org       = FEDORAPROJECT.ORG
      .stg.fedoraproject.org  = STG.FEDORAPROJECT.ORG
      stg.fedoraproject.org   = STG.FEDORAPROJECT.ORG
    '';

    realms."REDHAT.COM" = {
      kdc = "kerberos01.core.prod.int.ams2.redhat.com.:88";
      #kdc          = "kerberos02.core.prod.int.ams2.redhat.com.:88";
      admin_server = "kerberos.corp.redhat.com.:749";
    };
    realms."STG.FEDORAPROJECT.ORG" = {
      kdc = "https://id.stg.fedoraproject.org/KdcProxy";
    };
    realms."FEDORAPROJECT.ORG" = {
      kdc = "https://id.fedoraproject.org/KdcProxy";
    };

    appdefaults = {
      pam = {
        ticket_lifetime = "24h";
        renew_lifetime = "24h";
        forwardable = true;
        krb4_convert = false;
        proxiable = false;
        retain_after_close = false;
        minimum_uid = 0;
      };
    };
    extraConfig = ''
      [logging]
        kdc          = SYSLOG:NOTICE
        admin_server = SYSLOG:NOTICE
        default      = SYSLOG:NOTICE
    '';
  };
}
