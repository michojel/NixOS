{ config, lib, pkgs, ... }:

let
  wpArtifact = type: name: fn: hash: (pkgs.stdenv.mkDerivation {
    name = name;
    src = pkgs.fetchurl {
      url = "https://downloads.wordpress.org/${type}/${fn}.zip";
      sha256 = hash;
    };
    buildInputs = [ pkgs.unzip ];
    installPhase = "mkdir -p $out; cp -R * $out/";
  });

  asheTheme = pkgs.stdenv.mkDerivation
    {
      name = "ashe-theme";
      srcs = [
        (pkgs.fetchurl {
          url = "https://downloads.wordpress.org/theme/ashe.2.212.zip";
          sha256 = "sha256-WrOQMVV27kQA/4cC1Qi8oC0xRFFOMAakYAJo5cvpmKQ=";
        })
        ./wp/translations/ashe-cs_CZ.po
      ];

      sourceRoot = "ashe";
      buildInputs = [ pkgs.unzip pkgs.gettext ];
      unpackPhase = ''
        for _src in ''$srcs; do
          case "''$_src" in
            *.zip)
              ${pkgs.unzip}/bin/unzip "''$_src" -d ./
              ;;
            *)
              cp -v "''$_src" "$(basename "''$_src")"
              ;;
          esac
        done
      '';

      buildPhase = ''
        for f in ../*.po; do
          ${pkgs.gettext}/bin/msgfmt "$f" -o "''${f%.po}.mo"
        done
      '';

      installPhase = ''
        mkdir -p $out
        cp -R * $out/
        cp ../*cs_CZ.po $out/languages/cs_CZ.po
        cp ../*cs_CZ.mo $out/languages/cs_CZ.mo
      '';
    };

  asheProTheme = pkgs.stdenv.mkDerivation
    {
      name = "ashe-pro-theme";
      srcs = [
        /mnt/nixos/secrets/sites/wp/themes/ashe-pro-premium-latest.zip
        ./wp/translations/ashe-cs_CZ.po
      ];

      sourceRoot = "ashe-pro-premium";
      buildInputs = [ pkgs.unzip pkgs.gettext ];
      unpackPhase = ''
        for _src in ''$srcs; do
          case "''$_src" in
            *.zip)
              ${pkgs.unzip}/bin/unzip "''$_src" -d ./
              ;;
            *)
              cp -v "''$_src" "$(basename "''$_src")"
              ;;
          esac
        done
      '';

      buildPhase = ''
        for f in ../*.po; do
          ${pkgs.gettext}/bin/msgfmt "$f" -o "''${f%.po}.mo"
        done
      '';

      installPhase = ''
        mkdir -p $out
        cp -R * $out/
        cp ../*cs_CZ.po $out/languages/cs_CZ.po
        cp ../*cs_CZ.mo $out/languages/cs_CZ.mo
      '';
    };

in
{
  services = {
    wordpress = {
      webserver = "nginx";

      sites =
        let
          backgroundManagerPlugin = wpArtifact "plugin" "fully-background-manager"
            "fully-background-manager" "sha256-xCMMTWBOFJuMsxlfixakM0WZz+icDflqi74gBeu0rbY=";
          disableSitePlugin = wpArtifact "plugin" "disable-site-plugin"
            "disable-site" "sha256-QXUrhSgUd1zpnjSl0wR8FT2CC6M26WFyDhd/5//Q1qE=";
          locoTranslatePlugin = wpArtifact "plugin" "loco-translate-plugin"
            "loco-translate.2.6.4" "sha256-G4XhEQH9VHMyHcp/pH92cHKQAaqb0USeCURgNBhhpN0=";
          modulaPlugin = wpArtifact "plugin" "modula-plugin"
            "modula-best-grid-gallery.2.7.4" "sha256-b3a41yEHzYwvRW2wQ3zB8qcX7p7rw6tV2VgvFGk1fBA=";
          mapyPlugin = wpArtifact "plugin" "mapy-plugin"
            "wpify-mapy-cz.3.0.9" "sha256-7099qBz3e52mEmRjWOhOFBLaAQ85MNQTcIoIkYo9fZM=";

          /*
            asheTheme = wpArtifact "theme" "ashe-theme"
            "ashe.2.212" "sha256-WrOQMVV27kQA/4cC1Qi8oC0xRFFOMAakYAJo5cvpmKQ=";
          */
          bravadaTheme = wpArtifact "theme" "bravada-theme"
            "bravada.1.0.8" "sha256-ZGC+SuYIlnQ2ugpI8x6bAC/Jep/GQ8gxl8uGjlgruhs=";
          colibriTheme = wpArtifact "theme" "colibri-theme"
            "colibri-wp.1.0.92" "sha256-rvZIvIYBd64KpmrlaobBs56LNbOiaEf/h9BiSeBEL/c=";
          kadenceTheme = wpArtifact "theme" "kadence-theme"
            "kadence.1.1.35" "sha256-esR6Z5RXY902xnYV1zreQ9pkNbYWNgwtc5AgRqaewJU=";
          popularFxTheme = wpArtifact "theme" "popularfx-theme"
            "popularfx.1.2.4" "sha256-oHDiuXKH4Fv3eyeVCxHzYJUGu0jOTpHUm1HyLpOr91k=";
          responsiveTheme = wpArtifact "theme" "responsive-theme"
            "responsive.4.8.1" "sha256-IxlH8ffSZe1fZ9vIB6FfWUgmRKb7c9bPkUvsWmLzoDc=";
          skylineTheme = wpArtifact "theme" "skyline-theme"
            "skyline-wp.1.0.8" "sha256-suL75rNj+fs/U9rgjvz/fb2p+M1+8iIgsYeNxLakANU=";
          twentyElevenTheme = wpArtifact "theme" "twenty-eleven-theme"
            "twentyeleven.4.3" "sha256-QPrwE0XhUz3jfWoA8H820EdTE/BQ01yX1DMH9Zd63EE=";
          twentyseventeenTheme = wpArtifact "theme" "twenty-seventeen-theme"
            "twentyseventeen.3.2" "sha256-P2x+Qr27i5UDUZyq1Aw5NMGIdl5vXgFUJKleLoJ/uVI=";

          lang-cs = pkgs.stdenv.mkDerivation {
            name = "language-cs";
            src = pkgs.fetchurl {
              url = "https://cs.wordpress.org/wordpress-${pkgs.wordpress.version}-cs_CZ.tar.gz";
              name = "wordpress-${pkgs.wordpress.version}-language-cs.tar.gz";
              sha256 = "sha256-AIVz2+JtDQG1T3TKlZIoengJqh00eGVkYPaO/+tndfY=";
            };
            installPhase = "mkdir -p $out; cp -r ./wp-content/languages/* $out/";
          };

          wpSite = name: {
            database = {
              host = "127.0.0.1";
              createLocally = true;
            };
            extraConfig = ''
              define('DB_PASSWORD', file_get_contents('/var/keys/wordpress/${name}/db_password'));
            '';
            languages = [ lang-cs ];
            # ignored here, need to be specified in nginx.virtualHosts.<name>
            virtualHost = {
              enableACME = true;
              forceSSL = true;
            };
          };

        in
        {
          "laskavoucestou.cz" = lib.attrsets.recursiveUpdate (wpSite "laskavoucestou.cz") {
            database = {
              name = "laskavoucestou";
            };
            themes = with pkgs.wordpressPackages.themes; [ twentyseventeenTheme ];
            plugins = with pkgs.wordpressPackages.plugins; [
              akismet
              backgroundManagerPlugin
              disableSitePlugin
              locoTranslatePlugin
              mapyPlugin
              modulaPlugin
              wp-statistics
            ];
          };

          "lesnicestou.cz" = lib.attrsets.recursiveUpdate (wpSite "lesnicestou.cz") {
            database = {
              name = "lesnicestou";
            };
            themes = [ responsiveTheme twentyElevenTheme asheTheme asheProTheme skylineTheme colibriTheme bravadaTheme kadenceTheme popularFxTheme ];
            plugins = with pkgs.wordpressPackages.plugins; [
              akismet
              backgroundManagerPlugin
              disableSitePlugin
              locoTranslatePlugin
              mapyPlugin
              modulaPlugin
              wp-statistics
            ];
          };
        };

    };

    nginx.virtualHosts = {
      "laskavoucestou.cz" = {
        enableACME = true;
        forceSSL = true;
      };

      "lesnicestou.cz" = {
        enableACME = true;
        forceSSL = true;
      };
      "www.lesnicestou.cz" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "lesnicestou.cz";
      };
      "lesnicestou.michojel.cz" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "lesnicestou.cz";
      };
    };
  };
}
