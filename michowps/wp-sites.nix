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
            "advanced-google-recaptcha.1.17" "sha256-IBgNyI331P3VVQcx5oPwybrKV7PUWz5VPe5TrAoWVKs=";
          backgroundManagerPlugin = wpArtifact "plugin" "fully-background-manager"
            "fully-background-manager" "sha256-xCMMTWBOFJuMsxlfixakM0WZz+icDflqi74gBeu0rbY=";
          disableSitePlugin = wpArtifact "plugin" "disable-site-plugin"
            "disable-site" "sha256-QXUrhSgUd1zpnjSl0wR8FT2CC6M26WFyDhd/5//Q1qE=";
          forceLoginPlugin = wpArtifact "plugin" "force-login"
            "wp-force-login.5.6.3" "sha256-IImyQ174kxFkpERysoWujDcWw9bfVA8oID+DIHCRNzE=";
          groupsPlugin = wpArtifact "plugin" "groups"
            "groups" "sha256-crP/PEyq+72jgaaEoylTwIupnR1HqAF/c6EA+fgLrn0=";
          locoTranslatePlugin = wpArtifact "plugin" "loco-translate-plugin"
            "loco-translate.2.6.6" "sha256-qISTickGS1S1HyHp9P0a5KINsO49/TH+t4r5awLaY0w=";
          modulaPlugin = wpArtifact "plugin" "modula-plugin"
            "modula-best-grid-gallery.2.7.9" "sha256-3RBLD291v6tAy+sBK064Yna9qbH35BcFn0sCtYtAW7M=";
          mapyPlugin = wpArtifact "plugin" "mapy-plugin"
            "wpify-mapy-cz.3.1.2" "sha256-2MSfQr10EMq39KraYE9F+byYvyeOZpNZVN3CnEdx7mI=";
          headAndFooterCodePlugin = wpArtifact "plugin" "head-footer-code"
            "head-footer-code.1.3.3" "sha256-wfYnzg0g12b8/G/V2+IiDDiGZ3vp5gf3n+mn33XJffE=";

          twentyseventeenTheme = wpArtifact "theme" "twenty-seventeen-theme"
            "twentyseventeen.3.4" "sha256-CIkzrHxBLLs+BqK5DORSOeoZvyB7z7yd6e8L2PgYZHg=";

          lang-cs = pkgs.stdenv.mkDerivation {
            name = "language-cs";
            src = pkgs.fetchurl {
              url = "https://cs.wordpress.org/wordpress-${pkgs.wordpress.version}-cs_CZ.tar.gz";
              name = "wordpress-${pkgs.wordpress.version}-language-cs.tar.gz";
              sha256 = "0xwpj2iqjqrmdk60mdvahvx3g99qpc3ldp7fp85n7dkyazc697pz";
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
              akismet
              advancedGoogleRecaptcha
              backgroundManagerPlugin
              disableSitePlugin
              locoTranslatePlugin
              mapyPlugin
              modulaPlugin
              wp-statistics
              headAndFooterCodePlugin
            ];
          };

          "putovani.laskavoucestou.cz" = lib.attrsets.recursiveUpdate (wpSite "putovani.laskavoucestou.cz") {
            database = {
              name = "putovanilaskavoucestou";
            };
            themes = with pkgs.wordpressPackages.themes; [ asheProTheme ];
            plugins = with pkgs.wordpressPackages.plugins; [
              akismet
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
              akismet
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
