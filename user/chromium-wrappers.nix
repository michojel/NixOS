{ pkgs ? import <nixpkgs> {}, ... }:

with pkgs;
let
  dataDirBase = "/home/miminar/.config/chromium";
  workProfile = "RedHat";
  defaultWMClass = "Chromium";
  defaultIcons = {
    Default = "Chromium_Logo.svg";
    RedHat = "rht-chromium.svg";
  };
  defaultIcon = { profile ? "Default", icon ? null }:
    let
      p = if profile == null then "Default" else profile;
    in
      (if icon == null then defaultIcons."${p}" else icon);

  # as of chromium 80.0*, the "--class" parameter is disregarded
  # it is overrided by chromium with "crx_$appId"
  mkWMClass = { profile ? null, appId ? null }: (
    if appId != null then
      ("crx_" + lib.toLower appId)
    else
      (
        "${defaultWMClass}" + (lib.optionalString (profile != null) ("." + lib.toLower profile))
        + (lib.optionalString (appId != null) (".crx_" + lib.toLower appId))
      )
  );

  mkDesktopItem =
    { name
    , profile ? null
    , appId ? null
    , icon ? null
    , longName ? null
    , description ? null
    , comment ? null
    , categories ? null
    , mimeTypes ? null
    }: (
      makeDesktopItem {
        name = name;
        desktopName = longName;
        genericName = description;
        icon = icon;
        exec = name;
        categories = if (categories != null) then lib.concatStringsSep ";" categories else "Network;WebBrowser";
        mimeType = lib.optionalString (mimeTypes != null) (lib.concatStringsSep ";" mimeTypes);
        startupNotify = "true";
        extraEntries = "StartupWMClass=" + mkWMClass { inherit profile appId; };
      }
    );

  mkWrapper =
    { name
    , profile ? null
    , appId ? null
    , icon ? null
    , longName ? null
    , description ? null
    , comment ? null
    , categories ? null
    , mimeTypes ? null
      # TODO
    , overrideAppIcons ? false
    }:
      let
        icon_ = defaultIcon { inherit profile icon; };
        desktopItem = mkDesktopItem {
          inherit name profile appId longName description comment categories mimeTypes;
          icon = icon_;
        };
        pngname = lib.replaceStrings [ ".svg" ] [ ".png" ] icon_;
        userDataDir = dataDirBase + (lib.optionalString (profile != null) ("-" + lib.toLower profile));
      in
        lib.concatStringsSep "\n" [
          (
            lib.concatStringsSep
              " "
              (
                [
                  "makeWrapper"
                  "${chromium}/bin/chromium"
                  "$out/bin/${name}"
                  "--add-flags"
                  ("--user-data-dir=" + userDataDir)
                  "--add-flags"
                  ("--class=" + mkWMClass { inherit profile appId; })
                ] ++ (
                  if (appId != null) then
                    [ "--add-flags" "--app-id=${appId}" ]
                  else []
                ) ++ (
                  if (profile == workProfile) then
                    [ "--add-flags" ''--auth-server-whitelist="*.redhat.com"'' ]
                  else []
                )
              )
          )

          ''
            pushd ${desktopItem}
              find "share/applications" -type f | xargs -i ln -v -s "${desktopItem}/{}" "$out/{}"
            popd
          ''

          ''
            dest="$out/share/icons/${pngname}"
            if [[ ! -e "''$dest" ]]; then
              convert +antialias -background transparent -size 128x128 -verbose \
                "chromium-wrappers/${icon_}" "$dest"
            fi
          ''

          ''
            for size in 16x16 24x24 32x32 48x48 64x64 72x72 96x96 128x128 192x192 256x256 512x512 1024x1024; do
              dest="$out/share/icons/hicolor/$size/apps/${pngname}"
              [[ -e "$dest" ]] && continue
              mkdir -p "$(dirname "$dest")"
              convert +antialias -background transparent -size $size "chromium-wrappers/${icon_}" "$dest"
              # TODO: overlay RedHat icons with Hat:
              #   https://www.imagemagick.org/discourse-server/viewtopic.php?t=20251
              #   convert  background.jpg  tool_marker.png -geometry +50+50 -composite result4.jpg
            done
          ''

          (
            if overrideAppIcons && appId != null then
              ''
                # A file of format:
                #   { "$userDataDir": {
                #       "$appId": {
                #         "icon-name": "$iconName"
                #       }
                #   }
                # TODO: create a user systemd service to process this and update app icons
                dest="$out/share/chromium-wrappers/app-icons-to-override.json"
                jq '.["${userDataDir}"] |= ((. // {}) * {"${appId}": {"icon-name": "${icon_}"}})' \
                    <<<"$(cat "$dest" 2>/dev/null || printf '{}')" | \
                  sponge "$dest"
              ''
            else ""
          )
        ];

  mkRHTWrapper = { name, ... }@args: mkWrapper (args // { profile = workProfile; });

  wrappers = [
    (
      mkWrapper {
        name = "chromium-private";
        longName = "Personal Chromium Browser";
      }
    )
    (
      mkWrapper {
        name = "gcalendar";
        longName = "Personal Google Calendar";
        appId = "kjbdgfilnfhdoflbpgamdcdgpehopbep";
        icon = "Google_Calendar_icon.svg";
        overrideAppIcons = true;
      }
    )
    (
      mkWrapper {
        name = "gcontacts";
        longName = "Personal Google Contacts";
        appId = "jbeoliebicnmljhmdbbdeljdpjbfollk";
        icon = "Google_Contacts_icon.svg";
      }
    )
    (
      mkWrapper {
        name = "gdocs";
        longName = "GDocs - Personal Google Docs";
        appId = "bojccfnmcnekjgjhcaklmcgofnngpjcl";
        icon = "Google_Docs_logo.svg";
      }
    )
    (
      mkWrapper {
        name = "gsheets";
        longName = "Personal Google Sheets";
        appId = "lcahnhkcfaikkapifpaenbabamhfnecc";
      }
    )
    (
      mkWrapper {
        name = "gdrive";
        longName = "Personal Google Drive";
        appId = "lkdnjjllhbbhgjfojnheoooeabjimbka";
        icon = "Logo_of_Google_Drive.svg";
        overrideAppIcons = true;
      }
    )
    (
      mkWrapper {
        name = "gravit";
        longName = "Gravit Online";
        appId = "pdagghjnpkeagmlbilmjmclfhjeaapaa";
        icon = "gravit.svg";
      }
    )
    (
      mkWrapper {
        name = "duolingo";
        longName = "Duolingo";
        appId = "aiahmijlpehemcpleichkcokhegllfjl";
      }
    )
    (
      mkWrapper {
        name = "gmail";
        longName = "GMail - Personal Google Mail";
        appId = "pjkljhegncpnkpknbcohdijeoejaedia";
        icon = "Gmail_Icon.svg";
      }
    )
    (
      mkWrapper {
        name = "gmaps";
        longName = "GMaps - Google Maps";
        appId = "lneaknkopdijkpnocmklfnjbeapigfbh";
      }
    )
    (
      mkWrapper {
        name = "mapy";
        longName = "Seznam Mapy";
        appId = "mnadlckdoclecdmddabnbgjnkfoiddpd";
      }
    )
    (
      mkWrapper {
        name = "mega";
        longName = "Mega in Chromium";
        appId = "ockmlcfhhimcljikencdeppnoljjjfjk";
        icon = "mega.svg";
      }
    )
    (
      mkWrapper {
        name = "gmessages";
        longName = "Personal Google Messages";
        appId = "hpfldicfbfomlpcikngkocigghgafkph";
        icon = "android-messages-seeklogo.com.svg";
      }
    )
    (
      mkWrapper {
        name = "gphotos";
        longName = "GPhotos - Photos on Google";
        appId = "blckliiiahkijfikcfmbncibcefakemp";
        icon = "Google_Photos_icon.svg";
      }
    )
    (
      mkWrapper {
        name = "skypeweb";
        longName = "Skype on Web";
        appId = "bjdilgfelnbljgdpngladebaeggachpa";
        icon = "Skype_logo_(2019–present).svg";
      }
    )
    (
      mkWrapper {
        name = "whatsapp";
        longName = "Whatsapp";
        appId = "hnpfjngllnobngcgfapefoaidbinmjnm";
        icon = "WhatsApp.svg";
      }
    )
    #(mkWrapper { name = "wikics"; appId = "enjdmlmicjdnokcbaeajgmnippjnkfmo"; })
    #(mkWrapper { name = "wikide"; appId = "bhdbngpdfcdnndblpfphbmkajcbpnean"; })
    #(mkWrapper { name = "wikien"; appId = "mopbmgngnfadcehgbmkgjblgbhiehmlm"; })
    #(mkWrapper { name = "wikiru"; appId = "oenmclfdgkfbfladdhglinfmbbgnljhj"; })
    (
      mkWrapper {
        name = "webflow";
        longName = "Webflow";
        appId = "fjjpcpdfpiaiifjpdjeilpjolhkcdpne";
        icon = "webflow-black.ef3f174957.svg";
      }
    )
    (
      mkWrapper {
        name = "wireweb";
        longName = "Wire on Web";
        appId = "kfhkficiiapojlgcnbkgacfjmpffgoki";
      }
    )
    (
      mkWrapper {
        name = "youtube";
        longName = "Youtube";
        appId = "blpcfgokakmgnkcojhhkbfbldkacnbeo";
        icon = "YouTube_social_white_squircle_(2017).svg";
      }
    )
    (
      mkWrapper {
        name = "ytmusic";
        longName = "Youtube Music";
        appId = "cinhimbnkkaeohfgghhklpknlkffjgod";
        icon = "Youtube_Music_logo.svg";
      }
    )

    (
      mkRHTWrapper {
        name = "chromium-work";
        longName = "RHT Chromium Browser";
      }
    )
    (
      mkRHTWrapper {
        name = "ibmbox";
        longName = "IBM Box";
        appId = "gckfeldgkmajgieiakjfpmoahpajonjg";
      }
    )
    (
      mkRHTWrapper {
        name = "rhbj";
        longName = "RHT Bluejeans";
        appId = "mncjkohjkaeaoabfmhdefaflkcjjkmdd";
      }
    )
    (
      mkRHTWrapper {
        name = "rhgcalendar";
        longName = "RHT Calendar";
        appId = "kjbdgfilnfhdoflbpgamdcdgpehopbep";
        icon = "Google_Calendar_icon.svg";
      }
    )
    (
      mkRHTWrapper {
        name = "rhgchat";
        longName = "RHT Google Chat";
        appId = "pommaclcbfghclhalboakcipcmmndhcj";
      }
    )
    (
      mkRHTWrapper {
        name = "rhgmessages";
        longName = "RHT Messages";
        appId = "kpbdgbekoclglmjckpbanehbpjnlphkf";
      }
    )
    (
      mkRHTWrapper {
        name = "rhgdocs";
        longName = "RHT Google Docs";
        appId = "gcefppfnjnmndpknenooeofkfcbakpkp";
      }
    )
    (
      mkRHTWrapper {
        name = "rhgdrive";
        longName = "RHT Google Drive";
        appId = "lkdnjjllhbbhgjfojnheoooeabjimbka";
        icon = "Logo_of_Google_Drive.svg";
      }
    )
    (
      mkRHTWrapper {
        name = "rhgmail";
        longName = "RHT Google Mail";
        appId = "nkcknjnfmnmjahcahhhjgakeikoiomof";
        icon = "Gmail_Icon.svg";
      }
    )
    (
      mkRHTWrapper {
        name = "rhgsheets";
        longName = "RHT Google Sheets";
        appId = "albjknpbljlpmmpfjicdohagjcifagdi";
      }
    )
    (
      mkRHTWrapper {
        name = "sapcalendar";
        longName = "SAP Calendar";
        appId = "oeogacjkgmanlfjadbnhngnpbkibgfhj";
      }
    )
    (
      mkRHTWrapper {
        name = "sapdrive";
        longName = "SAP Drive";
        appId = "phgkmbchjgnehfpnmbekcoclneeojdma";
      }
    )
    (
      mkRHTWrapper {
        name = "sapmail";
        longName = "SAP Mail";
        appId = "plnbadkpncgbnekpephdpooeafambhak";
      }
    )
    (
      mkRHTWrapper {
        name = "sapteams";
        longName = "SAP Teams";
        appId = "jofcjnlbhnljdeapdjgodjlakohpfnjo";
        icon = "Microsoft_Office_Teams_(2018–present).svg";
      }
    )
  ];
in
stdenv.mkDerivation
  {
    name = "chromium-wrappers";
    version = chromium.version;
    meta = chromium.meta;
    nativeBuildInputs = [ makeWrapper chromium imagemagick ];
    buildInputs = [ moreutils jq ];
    runtimeDependencies = [ chromium kerberos ];
    phases = [ "unpackPhase" "installPhase" ];
    srcs = [
      ./pics/chromium-wrappers
    ];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/share/applications $out/share/icons $out/share/chromium-wrappers
    '' + lib.concatStringsSep "\n" wrappers;
  }
