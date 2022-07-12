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
          url = https://downloads.wordpress.org/plugin/akismet.4.1.10.zip;
          sha256 = "0d6m2h04x2pjpz4bnxcbb7mv3b221p2hsmys6r3jcpgbil025hfj";
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
          url = https://downloads.wordpress.org/plugin/modula-best-grid-gallery.2.5.3.zip;
          sha256 = "199qwv2k1d62n8qqk47irb2jcfys3vpz87xlmklpfmabh1hwgwf9";
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
          url = https://downloads.wordpress.org/theme/bravada.1.0.3.1.zip;
          sha256 = "1q1g00pskr7z4mws4jvn1bxxd1licavzjikvpbg7y1zwh109rn1k";
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
          url = https://downloads.wordpress.org/theme/kadence.1.0.11.zip;
          sha256 = "11i2367dz2vsqddhwzwh9zlk075n44l07ra5s0jjssp2qya8m3x8";
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
          url = https://downloads.wordpress.org/theme/popularfx.1.1.9.zip;
          sha256 = "1221jjs1fpbrm0m1baacxh7i14kjkds8rwxxc3qvj0jclyfnbfbg";
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
          url = https://downloads.wordpress.org/theme/colibri-wp.1.0.81.zip;
          sha256 = "1sjvz63lhlrkqgwgng7z7k7jy6vjhw5wnpag9kwqy8z0ks8pbqsj";
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
          url = https://downloads.wordpress.org/theme/skyline-wp.1.0.3.zip;
          sha256 = "0q5gh777v745cs1y8z8vnqj43yh6vr7js1s6h0knq4klq387dd2i";
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
          url = https://downloads.wordpress.org/theme/ashe.1.9.7.99.03.zip;
          sha256 = "09r22iqalq1f6v8hd7gdw74017ani7k2v26a43fljyjfp0xc2y03";
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
          url = https://downloads.wordpress.org/theme/twentyeleven.3.6.zip;
          sha256 = "04baww3sqpqq10nq0k4inv52s9xvdql4vwx8cadj9gbfy3rn445w";
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
          url = https://downloads.wordpress.org/theme/twentyseventeen.2.8.zip;
          sha256 = "1hqla7vm0c1fqn330va27d16mcfscrapxfy51byjpqylj6lh6yiw";
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
        plugins = [ akismetPlugin modulaPlugin disableSitePlugin backgroundManagerPlugin ];
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
