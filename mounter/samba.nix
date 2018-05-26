{ config, pkgs, ... }:

{
  services.samba = {
    enable = true;

    syncPasswordsByPam = true;
    invalidUsers = []; # by default, root is invalid

    extraConfig =
     ''
       WORKGROUP = minap50
       netbios name = ${config.networking.hostName}
       unix extensions = no
       follow symlinks = yes
       wide links = no
       map to guest = Bad User
       #interfaces = lo enp0s8
       interfaces = lo 192.168.56.0/255.255.255.0
       bind interfaces only = yes
       map archive = no
     '';


    shares = {
      minap50home = {
        browseable  = "yes";
        comment     = "minap50 home";
        path        = "/home";
        "read only" = "yes";
      };

      minap50etc = {
        browseable        = "no";
        comment           = "minap50 etc";
        "follow symlinks" = "yes";
        path              = "/mnt/minap50root/etc";
        "read only"       = "yes";
        "wide links"      = "yes";
      };

      miminar-documents = {
        browseable      = "yes";
        comment         = "miminar's documents";
        "force user"    = "miminar";
        group           = "users";
        path            = "/home/miminar/Documents";
        "read only"     = "yes";
      };

      miminar-docsrw = {
        browseable   = "no";
        comment      = "miminar's documents - writable";
        path         = "/home/miminar/Documents";
        "read only"  = "no";
        "force user" = "miminar";
        group        = "users";
      };

      miminar-anki = {
        browseable   = "yes";
        comment      = "miminar's synchronized anki profile";
        "force user" = "miminar";
        group        = "users";
        path         = "/home/miminar/Documents/memory/anki/synchronized";
        "read only"  = "no";
      };

      miminar-audio = {
        browseable   = "yes";
        comment      = "miminar's audio files";
        "force user" = "miminar";
        group        = "users";
        path         = "/home/miminar/Audio";
        "read only"  = "yes";
      };

      miminar-video = {
        browseable   = "yes";
        comment      = "miminar's video files";
        "force user" = "miminar";
        group        = "users";
        path         = "/home/miminar/Video";
        "read only"  = "yes";
      };

      miminar-pictures = {
        browseable   = "yes";
        comment      = "miminar's Pictures";
        "force user" = "miminar";
        group        = "users";
        path         = "/home/miminar/Pictures";
        "read only"  = "yes";
      };

      miminar-wsp = {
        browseable   = "yes";
        comment      = "miminar's workspace";
        "force user" = "miminar";
        group        = "users";
        path         = "/home/miminar/wsp";
        "read only"  = "no";
      };

      miminar-downloads = {
        browseable   = "yes";
        comment      = "miminar's downloads";
        "force user" = "miminar";
        group        = "users";
        path         = "/home/miminar/Downloads";
        "read only"  = "no";
      };

      miminar-ebooks = {
        browseable   = "yes";
        comment      = "miminar's books";
        "force user" = "miminar";
        group        = "users";
        path         = "/home/miminar/EBooks";
        "read only"  = "yes";
      };

      miminar-hexchat = {
        browseable        = "yes";
        comment           = "miminar's hexchat folder";
        "follow symlinks" = "yes";
        "force user"      = "miminar";
        group             = "users";
        path              = "/home/miminar/.config/hexchat";
        "read only"       = "no";
        "wide links"      = "yes";
      };
    };
  };
}
