{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;
let
  dataDirBase = "/home/michojel/.config/google-chrome";
  workProfile = "ETHZ";
  defaultWMClass = "Google-chrome";
  defaultIcons = {
    Default = "Chrome_Logo.svg";
    ETHZ = "ETH_Chrome_Logo.png";
  };
  ethzIcon = "ETH_Zürich_Logo.svg";
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
      # the suffix of the first item of WM_CLASS when running xprop on the window (without the crx_ prefix)
    , appId ? null
    , icon ? null
    , longName ? null
    , description ? null
    , comment ? null
    , categories ? null
    , mimeTypes ? [ ]
    }: (
      makeDesktopItem {
        name = name;
        desktopName = longName;
        genericName = description;
        icon =
          let
            parts = lib.strings.splitString "." icon;
          in
          lib.concatStringsSep "." (lib.lists.take ((lib.length parts) - 1) parts);
        exec = name;
        categories = if (categories != null) then categories else [ "Network" "WebBrowser" ];
        mimeTypes = mimeTypes;
        startupNotify = true;
        startupWMClass = mkWMClass { inherit profile appId; };
      }
    );

  cnvFunc = ''
    function cnv() {
      local size="$1"
      local srcFN="$2"
      local dest="$3"
      local addETH="$4"
      shift 4
      local geom="''${size}x''${size}"
      local offset="$(bc <<<"define max(a, b) { if (a < b) return (b); return (a); };
        max(1, $size / 75)")"
      local shadowArgs=(
        95          # opacity
        $((s/20))   # width on all sides
        "$offset"   # horizontal offset
        "$offset"   # vertical offset
      )
      local shadow="$(printf '%sx%s+%s+%s' "''${shadowArgs[@]}")"
      local convertArgs=( +antialias -gravity center -resize "$geom" -extent "$geom" )

      if [[ "$addETH" =~ ^(1|[tT]rue|[yY]es) ]]; then
        convertArgs=( -gravity SouthEast \
                      -resize $((size*4/5))x$((size*4/5)) -extent "$geom"
                      \( "chrome-wrappers/${ethzIcon}" \
                         -resize $((size*4/5))x$((size*4/5)) -rotate -45 \
                         -trim +repage -gravity NorthWest -extent "$geom" \)
                      \( +clone -background black -shadow "$shadow" \)
                      +swap -background none -flatten )
      fi
      convert -background transparent \
        "chrome-wrappers/''${srcFN}" "''${convertArgs[@]}" "$@" "$dest"
    }
    export -f cnv
  '';

  mkWrapper =
    { name
    , profile ? null
    , appId ? null
    , icon ? null
    , annotateWithETH ? false
    , longName ? null
    , description ? null
    , comment ? null
    , categories ? null
    , mimeTypes ? [ ]
      # TODO
    , overrideAppIcons ? false
    }:
    let
      addETH = icon != null && annotateWithETH;
      icon_ = defaultIcon { inherit profile icon; };
      pngname = lib.replaceStrings
        [ ".svg" ]
        [ ((lib.optionalString addETH "-with-hat") + ".png") ]
        icon_;
      desktopItem = mkDesktopItem {
        inherit name profile appId longName description comment categories mimeTypes;
        icon = pngname;
      };
      userDataDir = dataDirBase + (lib.optionalString (profile != null) ("-" + lib.toLower profile));
    in
    lib.concatStringsSep "\n" [
      (
        lib.concatStringsSep
          " "
          (
            [
              "makeWrapper"
              "${google-chrome}/bin/google-chrome-stable"
              "$out/bin/${name}"
              "--add-flags"
              ("--user-data-dir=" + userDataDir)
              "--add-flags"
              ("--class=" + mkWMClass { inherit profile appId; })
            ] ++ (
              if (appId != null) then
                [ "--add-flags" "--app-id=${appId}" ]
              else [ ]
            ) ++ (
              if (profile == workProfile) then
                [ "--add-flags" ''--auth-server-whitelist="*.redhat.com"'' ]
              else [ ]
            )
          )
      )

      ''
        pushd ${desktopItem}
          find "share/applications" -type f | xargs -i ln -v -s "${desktopItem}/{}" "$out/{}"
        popd

        addETH=${if addETH then "1" else "0"};
        dest="$out/share/icons/${pngname}"
        if [[ ! -e "''$dest" ]]; then
          parallel "''${parargs[@]}" cnv 128 "${icon_}" "$dest" "$addETH" -verbose
        fi

        for size in 16 24 32 48 64 72 96 128 192 256 512 1024; do
          dest="$out/share/icons/hicolor/''${size}x''${size}/apps/${pngname}"
          [[ -e "$dest" ]] && continue
          mkdir -p "$(dirname "$dest")"
          parallel "''${parargs[@]}" cnv "$size" "${icon_}" "$dest" "$addETH"
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
            dest="$out/share/chrome-wrappers/app-icons-to-override.json"
            jq '.["${userDataDir}"] |= ((. // {}) * {"${appId}": {"icon-name": "${icon_}"}})' \
                <<<"$(cat "$dest" 2>/dev/null || printf '{}')" | \
              sponge "$dest"
          ''
        else ""
      )
    ];

  mkETHWrapper = { name, ... }@args: mkWrapper ({ profile = workProfile; annotateWithETH = true; } // args);

  wrappers = [
    (mkWrapper {
      name = "chrome-private";
      longName = "Personal Chrome Browser";
    })
    (mkWrapper {
      name = "feedly";
      longName = "Feedly";
      appId = "hipbfijinpcgfogaopmgehiegacbhmob";
      icon = "feedly.svg";
    })
    (mkWrapper {
      name = "gcalendar";
      longName = "Personal Google Calendar";
      appId = "kjbdgfilnfhdoflbpgamdcdgpehopbep";
      icon = "Google_Calendar_icon.svg";
      overrideAppIcons = true;
    })
    (mkWrapper {
      name = "gcontacts";
      longName = "Personal Google Contacts";
      appId = "jbeoliebicnmljhmdbbdeljdpjbfollk";
      icon = "Google_Contacts_icon.svg";
    })
    (mkWrapper {
      name = "gdocs";
      longName = "GDocs - Personal Google Docs";
      appId = "bojccfnmcnekjgjhcaklmcgofnngpjcl";
      icon = "Google_Docs_logo.svg";
    })
    (mkWrapper {
      name = "gsheets";
      longName = "Personal Google Sheets";
      appId = "lcahnhkcfaikkapifpaenbabamhfnecc";
      icon = "google-sheets.svg";
    })
    (mkWrapper {
      name = "gdrive";
      longName = "Personal Google Drive";
      appId = "lkdnjjllhbbhgjfojnheoooeabjimbka";
      icon = "Logo_of_Google_Drive.svg";
      overrideAppIcons = true;
    })
    (mkWrapper {
      name = "grafana";
      longName = "Grafana - node exporter";
      appId = "imdkdbcaghfebdpapdilodeeenbbjkhe";
      icon = "grafana.svg";
    })
    (mkWrapper {
      name = "gravit";
      longName = "Gravit Online";
      appId = "pdagghjnpkeagmlbilmjmclfhjeaapaa";
      icon = "gravit256.png";
    })
    (mkWrapper {
      name = "duolingo";
      longName = "Duolingo";
      appId = "aiahmijlpehemcpleichkcokhegllfjl";
      icon = "duo_bicep_curl.svg";
    })
    (mkWrapper {
      name = "kindle";
      longName = "Kindle Cloud Reader";
      appId = "ecojfmkpfekmdhffinndgdcibnlehgig";
      icon = "bookerly-amazon-kindle.svg";
    })
    (mkWrapper {
      name = "gmail";
      longName = "GMail - Personal Google Mail";
      appId = "pjkljhegncpnkpknbcohdijeoejaedia";
      icon = "Gmail_Icon.svg";
    })
    (mkWrapper {
      name = "gmaps";
      longName = "GMaps - Google Maps";
      appId = "lneaknkopdijkpnocmklfnjbeapigfbh";
    })
    (mkWrapper {
      name = "mapy";
      longName = "Seznam Mapy";
      appId = "mnadlckdoclecdmddabnbgjnkfoiddpd";
    })
    (mkWrapper {
      name = "mega";
      longName = "Mega in Chrome";
      appId = "ockmlcfhhimcljikencdeppnoljjjfjk";
      icon = "mega.svg";
    })
    (mkWrapper {
      name = "gmessages";
      longName = "Personal Google Messages";
      appId = "hpfldicfbfomlpcikngkocigghgafkph";
      icon = "android-messages-seeklogo.com.svg";
    })
    (mkWrapper {
      name = "gphotos";
      longName = "GPhotos - Photos on Google";
      appId = "blckliiiahkijfikcfmbncibcefakemp";
      icon = "Google_Photos_icon.svg";
    })
    (mkWrapper {
      name = "messenger";
      longName = "Messenger";
      appId = "fmpeogjilmkgcolmjmaebdaebincaebh";
      icon = "Facebook_Messenger_4_Logo.svg";
    })
    (mkWrapper {
      name = "skypeweb";
      longName = "Skype on Web";
      appId = "bjdilgfelnbljgdpngladebaeggachpa";
      icon = "Skype_logo_2019–present.svg";
    })
    (mkWrapper {
      name = "whatsapp";
      longName = "Whatsapp";
      appId = "hnpfjngllnobngcgfapefoaidbinmjnm";
      icon = "WhatsApp.svg";
    })
    #(mkWrapper { name = "wikics"; appId = "enjdmlmicjdnokcbaeajgmnippjnkfmo"; })
    #(mkWrapper { name = "wikide"; appId = "bhdbngpdfcdnndblpfphbmkajcbpnean"; })
    #(mkWrapper { name = "wikien"; appId = "mopbmgngnfadcehgbmkgjblgbhiehmlm"; })
    #(mkWrapper { name = "wikiru"; appId = "oenmclfdgkfbfladdhglinfmbbgnljhj"; })
    (mkWrapper {
      name = "webflow";
      longName = "Webflow";
      appId = "fjjpcpdfpiaiifjpdjeilpjolhkcdpne";
      icon = "webflow-logo-with-shade.svg";
    })
    (mkWrapper {
      name = "wireweb";
      longName = "Wire on Web";
      appId = "kfhkficiiapojlgcnbkgacfjmpffgoki";
    })
    (mkWrapper {
      name = "youtube";
      longName = "Youtube";
      appId = "blpcfgokakmgnkcojhhkbfbldkacnbeo";
      icon = "YouTube_social_white_squircle_2017.svg";
    })
    (mkWrapper {
      name = "ytmusic";
      longName = "Youtube Music";
      appId = "cinhimbnkkaeohfgghhklpknlkffjgod";
      icon = "Youtube_Music_logo.svg";
    })

    (mkETHWrapper {
      name = "chrome-work";
      longName = "ETH Chrome Browser";
      annotateWithETH = false;
    })
    (mkETHWrapper {
      name = "rhgcalendar";
      longName = "ETH Calendar";
      appId = "ejldabfpdfkccfdfcgngicjpnmomajia";
      icon = "Google_Calendar_icon.svg";
    })
    (mkETHWrapper {
      name = "rhgdocs";
      longName = "ETH Google Docs";
      appId = "gcefppfnjnmndpknenooeofkfcbakpkp";
      icon = "Google_Docs_logo.svg";
    })
    (mkETHWrapper {
      name = "rhgdrive";
      longName = "ETH Google Drive";
      appId = "cikenbpahmagdhfiipmaokllliijldgn";
      icon = "Logo_of_Google_Drive.svg";
    })
    (mkETHWrapper {
      name = "rhgmail";
      longName = "ETH Google Mail";
      appId = "nkcknjnfmnmjahcahhhjgakeikoiomof";
      icon = "Gmail_Icon.svg";
    })
    (mkETHWrapper {
      name = "rhgsheets";
      longName = "ETH Google Sheets";
      appId = "albjknpbljlpmmpfjicdohagjcifagdi";
      icon = "google-sheets.svg";
    })
  ];
in
stdenv.mkDerivation {
  name = "chrome-wrappers";
  version = google-chrome.version;
  meta = google-chrome.meta;
  nativeBuildInputs = [ makeWrapper google-chrome imagemagick parallel bc ];
  buildInputs = [ moreutils jq ];
  runtimeDependencies = [ google-chrome chromium kerberos ];
  phases = [ "unpackPhase" "installPhase" ];
  srcs = [
    ./pics/chrome-wrappers
  ];
  sourceRoot = ".";
  installPhase = lib.concatStringsSep "\n" [
    ''
      N="$(parallel --number-of-threads)" ||:
      N="''${N:-$(parallel --number-of-cores)}" ||:
      N="''${N:-4}"
      parargs=( --will-cite --semaphore --jobs=$N --id=convert )
      export PARALLEL_HOME="$(pwd)/.parallel"
      mkdir -p "$PARALLEL_HOME"
      mkdir -p $out/share/applications $out/share/icons $out/share/chrome-wrappers
    ''
    cnvFunc
    (lib.concatStringsSep "\n" wrappers)
    ''
      parallel --will-cite --semaphore --wait --id=convert
    ''
  ];
}
