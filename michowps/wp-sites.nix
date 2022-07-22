{ config, lib, pkgs, ... }:

{
  imports = [
    ./nginx-wordpress.nix
  ];

  services.nginxWordpress.sites =
    let
      responsiveTheme = pkgs.stdenv.mkDerivation {
        name = "responsive-theme";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = http://wordpress.org/themes/download/responsive.4.5.2.zip;
          #sha256 = "06i26xlc5kdnx903b1gfvnysx49fb4kh4pixn89qii3a30fgd8r8";
          #sha256 = "1g1mjvjbx7a0w8g69xbahi09y2z8wfk1pzy1wrdrdnjlynyfgzq8";
          sha256 = "1y9npjq3279rcg61cbcwfz30dxdgl0gcj8bihlwkb07xhw5ar196";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      # Wordpress plugin 'akismet' installation example
      akismetPlugin = pkgs.stdenv.mkDerivation {
        name = "akismet-plugin";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/plugin/akismet.4.2.5.zip;
          sha256 = "sha256-HFRyJ01n61Bfd3bT6QbEZtqirJEG0mXZV7Q0SNP3Rik=";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      modulaPlugin = pkgs.stdenv.mkDerivation {
        name = "modula-plugin";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/plugin/modula-best-grid-gallery.2.6.7.zip;
          sha256 = "sha256-0MYkaPcVRCFFJ4ZFdqZU7pVFIooPHKdy/iEPr4pLOMA=";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      backgroundManagerPlugin = pkgs.stdenv.mkDerivation {
        name = "fully-background-manager";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/plugin/fully-background-manager.zip;
          sha256 = "0h6blvvsnzs72bjac0hzh4hjkxwg81ichdj1ab7c384mkrvj1vcv";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      disableSitePlugin = pkgs.stdenv.mkDerivation {
        name = "disable-site-plugin";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/plugin/disable-site.zip;
          sha256 = "18fns3zyfzqp1rr63s9nlc5q4g8mgh2d799lkvlmqxql522jnxa1";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };


      bravadaTheme = pkgs.stdenv.mkDerivation {
        name = "bravada-theme";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/theme/bravada.1.0.7.1.zip;
          sha256 = "0iq24r6by3mp0za41v5hjjlav4smbahjwg02h9x4rvs92h5qxg2m";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      kadenceTheme = pkgs.stdenv.mkDerivation {
        name = "kadence-theme";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/theme/kadence.1.1.22.zip;
          sha256 = "18n3h0q8wzpgvzwj5vif37ni51vcq3clc6wxl80g2prqc2s0j8gq";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      popularFxTheme = pkgs.stdenv.mkDerivation {
        name = "popularfx-theme";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/theme/popularfx.1.2.3.zip;
          sha256 = "17wjxr0kspsi7qdaj4by9frvd1bm8sj6h0rjncybnj7slq7dgqm7";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      colibriTheme = pkgs.stdenv.mkDerivation {
        name = "colibri-theme";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/theme/colibri-wp.1.0.88.zip;
          sha256 = "1bqbzy650mz0b76ij2d1mnzrk3fz5d1a83r5wmgmw7gqc1wfmlhb";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      skylineTheme = pkgs.stdenv.mkDerivation {
        name = "skyline-theme";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/theme/skyline-wp.1.0.6.zip;
          sha256 = "0g7cqdzi0npihpa70wa7vqlvjv6fyqk0a7n8bd3cqjyj56i8xxwv";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      asheTheme = pkgs.stdenv.mkDerivation {
        name = "ashe-theme";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/theme/ashe.2.199.zip;
          sha256 = "0hf0m1k469mk0ivvjn4s7hrkggw6y1a6mjqk2m7pjdrlnap9785f";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      twentyElevenTheme = pkgs.stdenv.mkDerivation {
        name = "twenty-eleven-theme";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/theme/twentyeleven.4.1.zip;
          sha256 = "08pnjigq9iw3r20ja441ivsx3n557bcx829i5spfqdxjgljggnki";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      twentyseventeenTheme = pkgs.stdenv.mkDerivation {
        name = "twenty-seventeen-theme";
        # Download the theme from the wordpress site
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/theme/twentyseventeen.3.0.zip;
          sha256 = "1lw5gvxzjzk5py475x2c0cnk8k8r574i0lhhxzhzqifz7vd4l352";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

      wp-statistics = pkgs.stdenv.mkDerivation {
        name = "wp-statistics";
        src = pkgs.fetchurl {
          url = https://downloads.wordpress.org/plugin/wp-statistics.13.2.4.1.zip;
          sha256 = "sha256-YTGF9PHa/BjYZjPSVcHGhPIHglExYVDFPrRipy90Qk8=";
        };
        # We need unzip to build this package
        buildInputs = [ pkgs.unzip ];
        # Installing simply means copying all files to the output directory
        installPhase = "mkdir -p $out; cp -R * $out/";
      };

    in
    {
      "laskavoucestou.cz" = {
        database = {
          host = "127.0.0.1";
          #user = "laskavoucestou";
          name = "laskavoucestou";
          passwordFile = "/var/keys/wordpress/laskavoucestou.cz/db_password";
          createLocally = true;
        };
        themes = [ twentyseventeenTheme responsiveTheme ];
        plugins = [ akismetPlugin modulaPlugin disableSitePlugin backgroundManagerPlugin wp-statistics ];
      };

      "lesnicestou.cz" = {
        database = {
          host = "127.0.0.1";
          #user = "laskavoucestou";
          name = "lesnicestou";
          passwordFile = "/var/keys/wordpress/lesnicestou.cz/db_password";
          createLocally = true;
        };
        domainName = "lesnicestou.michojel.cz";
        themes = [ responsiveTheme twentyElevenTheme asheTheme skylineTheme colibriTheme bravadaTheme kadenceTheme popularFxTheme ];
        plugins = [ akismetPlugin modulaPlugin disableSitePlugin ];
      };
    };
}
