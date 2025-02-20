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
          advancedGoogleRecaptcha = wpArtifact "plugin" "advanced-google-recaptcha"
            "advanced-google-recaptcha.1.22" "sha256-Po2IwLhFSPYGmFSiaWvYy/DkZKV+YKYYcaIR2BxZalc";
          # TODO: use stock akismet
          akismetPlugin = wpArtifact "plugin" "akismet"
            "akismet.5.3.5" "sha256-nnLWxgyOOtybICvWrYZZYFKJzQkh1flybavyTgalChY=";
          backgroundManagerPlugin = wpArtifact "plugin" "fully-background-manager"
            "fully-background-manager" "sha256-xCMMTWBOFJuMsxlfixakM0WZz+icDflqi74gBeu0rbY=";
          disableSitePlugin = wpArtifact "plugin" "disable-site-plugin"
            "disable-site" "sha256-QXUrhSgUd1zpnjSl0wR8FT2CC6M26WFyDhd/5//Q1qE=";
          forceLoginPlugin = wpArtifact "plugin" "force-login"
            "wp-force-login.5.6.3" "sha256-NB/JiDqR44kSZCEtzte44ZshqhH/Vw1GiX+RclvL+3M=";
          groupsPlugin = wpArtifact "plugin" "groups"
            "groups.3.2.1" "sha256-8S8mmitYtHlQdX3kaIQYV1ynFuNdPEjKm3ieVcfSn94=";
          locoTranslatePlugin = wpArtifact "plugin" "loco-translate-plugin"
            "loco-translate.2.6.11" "sha256-UCFLP43JIlBa4BlCL3h3O9qV0AeboZG0HrXKKS4eUK0=";
          modulaPlugin = wpArtifact "plugin" "modula-plugin"
            "modula-best-grid-gallery.2.7.9" "sha256-3RBLD291v6tAy+sBK064Yna9qbH35BcFn0sCtYtAW7M=";
          mapyPlugin = wpArtifact "plugin" "mapy-plugin"
            "wpify-mapy-cz.3.1.11" "sha256-h/C6nD+yn3pYZ6c42mRNjHx2qQ5QQVF38Gqj2dN5jcU=";
          headAndFooterCodePlugin = wpArtifact "plugin" "head-footer-code"
            "head-footer-code.1.3.5" "sha256-8wbEpc3sx2mLsgmQpjWAfASLzdqTdYFJdWKTaCZknMY=";
          optionsForTwentySeventeen = wpArtifact "plugin" "options-for-twenty-seventeen"
            "options-for-twenty-seventeen.2.5.3" "sha256-Ohny3t54OdMqawFAWSW2Z0u8xElPN4Ghb1JE0OVvweI=";

          twentyseventeenTheme = wpArtifact "theme" "twenty-seventeen-theme"
            "twentyseventeen.3.7" "sha256-IVqrrj6c6klMASxBnzGDaozi+zIbQhC8zQXQ0mPWtyc=";

          lang-cs = pkgs.stdenv.mkDerivation {
            name = "language-cs";
            src = pkgs.fetchurl {
              # url = "https://cs.wordpress.org/wordpress-${pkgs.wordpress.version}-cs_CZ.tar.gz";
              # name = "wordpress-${pkgs.wordpress.version}-language-cs.tar.gz";
              ## TODO switch to the lines above once the translation is available
              url = "https://cs.wordpress.org/wordpress-6.6.2-cs_CZ.tar.gz";
              name = "wordpress-6.6.2-language-cs.tar.gz";
              sha256 = "sha256-zW3zurpDAM/8eYxusuTM6zpjW91flEhh6lsMEnMmVz0=";
            };
            installPhase = "mkdir -v -p $out; ls -l; pwd; cp -v -r ./wp-content/languages/* $out/";
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
              akismetPlugin
              advancedGoogleRecaptcha
              backgroundManagerPlugin
              disableSitePlugin
              locoTranslatePlugin
              mapyPlugin
              modulaPlugin
              wp-statistics
              headAndFooterCodePlugin
              optionsForTwentySeventeen
            ];
          };

          "putovani.laskavoucestou.cz" = lib.attrsets.recursiveUpdate (wpSite "putovani.laskavoucestou.cz") {
            database = {
              name = "putovanilaskavoucestou";
            };
            themes = with pkgs.wordpressPackages.themes; [ asheProTheme ];
            plugins = with pkgs.wordpressPackages.plugins; [
              akismetPlugin
              advancedGoogleRecaptcha
              #backgroundManagerPlugin
              #disableSitePlugin
              forceLoginPlugin
              groupsPlugin
              locoTranslatePlugin
              mapyPlugin
              modulaPlugin
              wp-statistics
              headAndFooterCodePlugin
            ];
          };

          "lesnicestou.cz" = lib.attrsets.recursiveUpdate (wpSite "lesnicestou.cz") {
            database = {
              name = "lesnicestou";
            };
            themes = [ asheProTheme ];
            plugins = with pkgs.wordpressPackages.plugins; [
              akismetPlugin
              advancedGoogleRecaptcha
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
      "putovani.laskavoucestou.cz" = {
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
