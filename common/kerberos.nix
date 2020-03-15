{ config, lib, pkgs, ... }:

{
  krb5 = {
    enable = true;

    domain_realm = {
      ".redhat.com" = "REDHAT.COM";
      "redhat.com" = "REDHAT.COM";
      ".fedoraproject.org" = "FEDORAPROJECT.ORG";
      "fedoraproject.org" = "FEDORAPROJECT.ORG";
    };

    libdefaults = {
      default_ccache_name = "KEYRING:persistent:%{uid}";
      default_realm = "REDHAT.COM";
      dns_lookup_kdc = false;
      dns_lookup_realm = "false";
      forwardable = "true";
      rdns = "false";
      renew_lifetime = "7d";
      ticket_lifetime = "24h";
    };

    realms = {
      "REDHAT.COM" = {
        "master_kdc" = "kerberos.corp.redhat.com";
        "admin_server" = "kerberos.corp.redhat.com";
        # TODO: allow for multiple kdc lines
        "kdc" = "kerberos01.core.prod.int.rdu2.redhat.com.:88";
        #"kdc" = "kerberos02.core.prod.int.rdu2.redhat.com";
        #"kdc" = "kerberos02.core.prod.int.phx2.redhat.com";
        #kdc = kerberos01.core.prod.int.phx2.redhat.com.:88
        #kdc = kerberos01.core.prod.int.ams2.redhat.com.:88
        #kdc = kerberos01.core.prod.int.sin2.redhat.com.:88
      };
      "FEDORAPROJECT.ORG" = {
        "kdc" = "https://id.fedoraproject.org/KdcProxy";
      };
    };
  };
}

# ex: set et ts=2 sw=2 :
