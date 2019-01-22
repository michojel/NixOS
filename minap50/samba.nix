{ config, pkgs, ... }:

{
  services.samba = {
    enable = true;

    #invalidUsers = []; # by default, root is invalid

    extraConfig =
     ''
       WORKGROUP = minap50
       netbios name = ${config.networking.hostName}
       unix extensions = no
       follow symlinks = yes
       wide links = no
       map to guest = Bad User
       interfaces = lo 192.168.56.0/255.255.255.0
       bind interfaces only = yes
       map archive = no
       encrypt passwords = yes
       smb passwd file = /mnt/nixos/secret/smbpasswd
       load printers = no
       printcap name = /dev/null
     '';

    shares = {
      rh-idrac = {
        browseable   = "yes";
        "read only"  = "true";
        comment      = "Share for Red Hat Dell System";
        "force user" = "miminar";
        group        = "users";
        path         = "/var/vmshare";
      };
    };
  };

  #users.extraUsers = config.users.extraUsers // {
  users.extraUsers = {
    smb-rhidrac = {
      uid = 10001;
      extraGroups  = [];
    };
  };
}
