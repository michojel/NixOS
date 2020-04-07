{ pkgs ? import <nixpkgs> {}, ... }:

with pkgs;
let
  dataDirBase = "/home/miminar/.config/chromium";
  workProfile = "RedHat";
  defaultWMClass = "Chromium";

  mkWMClass = { profile ? null, appId ? null }: (
    "${defaultWMClass}" + (lib.optionalString (profile != null) ("." + lib.toLower profile))
    + (lib.optionalString (appId != null) (".crx_" + lib.toLower appId))
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
    }:
      let
        desktopItem = mkDesktopItem {
          inherit name profile appId icon longName description comment categories mimeTypes;
        };
      in
        lib.concatStringsSep "\n" (
          [
            (
              lib.concatStringsSep
                " "
                (
                  [
                    "makeWrapper"
                    "${chromium}/bin/chromium"
                    "$out/bin/${name}"
                    "--add-flags"
                    ("--user-data-dir=" + dataDirBase + (lib.optionalString (profile != null) ("-" + lib.toLower profile)))
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

          ] ++ (
            if (icon != null) then (
              let
                pngname = lib.replaceStrings [ ".svg" ] [ ".png" ] icon;
              in
                [
                  ''convert +antialias -background transparent -verbose \
                      -size 128x128 "chromium-wrappers/${icon}" "$out/share/icons/${pngname}"''
                  ''
                    for size in 16x16 24x24 32x32 48x48 64x64 72x72 96x96 128x128 192x192 256x256 512x512 1024x1024; do
                      mkdir -p $out/share/icons/hicolor/$size/apps
                      convert +antialias -background transparent -verbose \
                          -size $size "chromium-wrappers/${icon}" "$out/share/icons/hicolor/$size/apps/${pngname}"
                    done
                  ''
                ]
            ) else []
          )
        );

  mkRHTWrapper = { name, ... }@args: mkWrapper (args // { profile = workProfile; });

  wrappers = [
    (mkWrapper { name = "chromium-private"; longName = "Personal Chromium Browser"; icon = "redhat.svg"; })
    (mkWrapper { name = "gcalendar"; longName = "Personal Google Calendar"; appId = "kjbdgfilnfhdoflbpgamdcdgpehopbep"; icon = "Google_Calendar_icon.svg"; })
    (mkWrapper { name = "gcontacts"; longName = "Personal Google Contacts"; appId = "jbeoliebicnmljhmdbbdeljdpjbfollk"; })
    (mkWrapper { name = "gdocs"; longName = "Personal Google Docs"; appId = "bojccfnmcnekjgjhcaklmcgofnngpjcl"; })
    (mkWrapper { name = "gsheets"; longName = "Personal Google Sheets"; appId = "lcahnhkcfaikkapifpaenbabamhfnecc"; })
    (mkWrapper { name = "gdrive"; longName = "Personal Google Drive"; appId = "lkdnjjllhbbhgjfojnheoooeabjimbka"; })
    (mkWrapper { name = "gravit"; longName = "Gravit Online"; appId = "pdagghjnpkeagmlbilmjmclfhjeaapaa"; })
    (mkWrapper { name = "duolingo"; longName = "Duolingo"; appId = "aiahmijlpehemcpleichkcokhegllfjl"; })
    (mkWrapper { name = "gmail"; longName = "Personal Google Mail"; appId = "pjkljhegncpnkpknbcohdijeoejaedia"; icon = "Gmail_Icon.svg"; })
    (mkWrapper { name = "gmaps"; longName = "Google Maps"; appId = "lneaknkopdijkpnocmklfnjbeapigfbh"; })
    (mkWrapper { name = "mapy"; longName = "Seznam Mapy"; appId = "mnadlckdoclecdmddabnbgjnkfoiddpd"; })
    (mkWrapper { name = "mega"; longName = "Mega in Chromium"; appId = "ockmlcfhhimcljikencdeppnoljjjfjk"; })
    (mkWrapper { name = "gmessages"; longName = "Personal Google Messages"; appId = "hpfldicfbfomlpcikngkocigghgafkph"; })
    (mkWrapper { name = "gphotos"; longName = "Google Photos"; appId = "blckliiiahkijfikcfmbncibcefakemp"; })
    (mkWrapper { name = "skypeweb"; longName = "Skype on Web"; appId = "bjdilgfelnbljgdpngladebaeggachpa"; })
    (mkWrapper { name = "whatsapp"; longName = "Whatsapp"; appId = "hnpfjngllnobngcgfapefoaidbinmjnm"; })
    #(mkWrapper { name = "wikics"; appId = "enjdmlmicjdnokcbaeajgmnippjnkfmo"; })
    #(mkWrapper { name = "wikide"; appId = "bhdbngpdfcdnndblpfphbmkajcbpnean"; })
    #(mkWrapper { name = "wikien"; appId = "mopbmgngnfadcehgbmkgjblgbhiehmlm"; })
    #(mkWrapper { name = "wikiru"; appId = "oenmclfdgkfbfladdhglinfmbbgnljhj"; })
    (mkWrapper { name = "webflow"; longName = "Webflow"; appId = "fjjpcpdfpiaiifjpdjeilpjolhkcdpne"; })
    (mkWrapper { name = "wireweb"; longName = "Wire on Web"; appId = "kfhkficiiapojlgcnbkgacfjmpffgoki"; })
    (mkWrapper { name = "youtube"; longName = "Youtube"; appId = "blpcfgokakmgnkcojhhkbfbldkacnbeo"; icon = "YouTube_social_white_squircle_(2017).svg"; })
    (mkWrapper { name = "ytmusic"; longName = "Youtube Music"; appId = "cinhimbnkkaeohfgghhklpknlkffjgod"; icon = "Youtube_Music_logo.svg"; })

    (mkRHTWrapper { name = "chromium-work"; longName = "RHT Chromium Browser"; })
    (mkRHTWrapper { name = "ibmbox"; longName = "IBM Box"; appId = "gckfeldgkmajgieiakjfpmoahpajonjg"; })
    (mkRHTWrapper { name = "rhbj"; longName = "RHT Bluejeans"; appId = "mncjkohjkaeaoabfmhdefaflkcjjkmdd"; })
    (mkRHTWrapper { name = "rhgcalendar"; longName = "RHT Calendar"; appId = "kjbdgfilnfhdoflbpgamdcdgpehopbep"; })
    (mkRHTWrapper { name = "rhgchat"; longName = "RHT Google Chat"; appId = "pommaclcbfghclhalboakcipcmmndhcj"; })
    (mkRHTWrapper { name = "rhgmessages"; longName = "RHT Messages"; appId = "kpbdgbekoclglmjckpbanehbpjnlphkf"; })
    (mkRHTWrapper { name = "rhgdocs"; longName = "RHT Google Docs"; appId = "gcefppfnjnmndpknenooeofkfcbakpkp"; })
    (mkRHTWrapper { name = "rhgdrive"; longName = "RHT Google Drive"; appId = "lkdnjjllhbbhgjfojnheoooeabjimbka"; })
    (mkRHTWrapper { name = "rhgmail"; longName = "RHT Google Mail"; appId = "nkcknjnfmnmjahcahhhjgakeikoiomof"; })
    (mkRHTWrapper { name = "rhgsheets"; longName = "RHT Google Sheets"; appId = "albjknpbljlpmmpfjicdohagjcifagdi"; })
    (mkRHTWrapper { name = "sapcalendar"; longName = "SAP Calendar"; appId = "oeogacjkgmanlfjadbnhngnpbkibgfhj"; })
    (mkRHTWrapper { name = "sapdrive"; longName = "SAP Drive"; appId = "phgkmbchjgnehfpnmbekcoclneeojdma"; })
    (mkRHTWrapper { name = "sapmail"; longName = "SAP Mail"; appId = "plnbadkpncgbnekpephdpooeafambhak"; })
    (mkRHTWrapper { name = "sapteams"; longName = "SAP Teams"; appId = "jofcjnlbhnljdeapdjgodjlakohpfnjo"; })
  ];
in
stdenv.mkDerivation {
  name = "chromium-wrappers";
  version = chromium.version;
  meta = chromium.meta;
  nativeBuildInputs = [ makeWrapper chromium imagemagick ];
  runtimeDependencies = [ chromium kerberos ];
  phases = [ "unpackPhase" "installPhase" ];
  srcs = [
    ./pics/chromium-wrappers
  ];
  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out/share/applications $out/share/icons
  '' + lib.concatStringsSep "\n" wrappers;
}
