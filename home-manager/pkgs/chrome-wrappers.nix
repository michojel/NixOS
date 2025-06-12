{ homeDir, pkgs ? import <nixpkgs> { }, disableGPU ? false }:

with pkgs;
let
  dataDirBaseForBrowser = {
    chrome = homeDir + "/.config/google-chrome";
    chromium = homeDir + "/.config/chromium";
  };
  defaultWMClassForBrowser = {
    chrome = "Google-chrome";
    chromium = "chromium-browser";
  };
  defaultBrowserForProfile = {
    Default = "chromium";
    ETHZ = "chromium";
    ETHZ-Admin = "chromium";
  };
  workProfile = "ETHZ";
  adminProfile = "ETHZ-Admin";
  defaultIcons = {
    Default = "Chrome_Logo.svg";
    ETHZ = "ETH_Chrome_Logo.png";
    ETHZ-Admin = "ETH_Admin-Chrome_Logo.png";
  };
  ethzIcon = "ETH_Zürich_Logo.svg";
  defaultIcon = { profile ? "Default", icon ? null, appId ? null }:
    if (icon == null && appId != null) then
      ("chrome-" + appId + "-" + profile)
    else
      (if icon == null then defaultIcons."${profile}" else icon);
  defaultBrowser = { browser ? null, profile ? "Default" }:
    let p = if profile == null then "Default" else profile;
    in
    if browser == null then
      defaultBrowserForProfile."${p}"
    else browser;
  defaultWMClass = { browser ? null, profile ? "Default" }:
    defaultWMClassForBrowser."${defaultBrowser { inherit browser profile;}}";
  defaultDataDirBase = { browser ? null, profile ? "Default" }:
    dataDirBaseForBrowser."${defaultBrowser { inherit browser profile; }}";

  # as of chromium 80.0*, the "--class" parameter is disregarded
  mkWMClass = { browser ? null, profile ? "Default", appId ? null }: (
    if appId != null then
    #("crx_" + (lib.toLower appId))
      ("chrome-" + (lib.toLower appId) + "-" + profile)
    else
      (
        "${defaultWMClass {inherit browser profile;}}" + (lib.optionalString (profile != null) ("." + lib.toLower profile))
      )
  );

  mkDesktopItem =
    { name
    , browser ? null
    , profile ? "Default"
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
          if (icon == null && appId != null) then
            ("chrome-" + appId + "-" + "profile")
          else
            (
              let
                parts = lib.strings.splitString "." icon;
              in
              lib.concatStringsSep "." (lib.lists.take ((lib.length parts) - 1) parts)
            );
        exec = name;
        categories = if (categories != null) then categories else [ "Network" "WebBrowser" ];
        mimeTypes = mimeTypes;
        # startupNotify = true;
        startupWMClass = mkWMClass { inherit browser profile appId; };
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

  overrideAppIconsScript = writeTextFile {
    name = "override-app-icons";
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      appId="$1"
      iconOverrides="$2"
      userDataDir="$3"
      iconName="$4"

      if [[ -z "''${appId}" ]]; then
        exit 0
      fi
      if [[ ! -e "''${userDataDir}" ]]; then
        mkdir -p -v "''${userDataDir}"
      fi

      find "''${userDataDir}" -type f -regex '.*/'"''${appId}"'/Icons.*\.png' | while read -r icon; do
        size="$(sed 's/.*[x/]\([0-9]\+\)\.png/\1/' <<<"$icon")"
        override="''${iconOverrides}/''${size}x''${size}/apps/''${iconName}"
        if [[ -e "''${override}" ]]; then
          ln -sfv "''${override}" "$icon"
        else
          echo rm -v "$icon"
        fi
      done
    '';
  };


  mkWrapper =
    { name
    , browser ? null
    , profile ? "Default"
    , appId ? null
    , icon ? null
    , annotateWithETH ? false
    , longName ? null
    , description ? null
    , comment ? null
    , categories ? null
    , mimeTypes ? [ ]
    , overrideAppIcons ? false
    }:
    let
      addETH = icon != null && annotateWithETH;
      icon_ = defaultIcon { inherit profile icon appId; };
      pngname =
        if appId != null then
          "chrome-" + appId + "-" + profile + ".png"
        else
          lib.replaceStrings
            [ ".svg" ]
            [ ((lib.optionalString addETH "-with-eth") + ".png") ]
            icon_;
      desktopItem = mkDesktopItem {
        inherit name browser profile appId longName description comment categories mimeTypes;
        icon = pngname;
      };
      userDataDir = (defaultDataDirBase { inherit browser profile; }) + (lib.optionalString (profile != null) ("-" + lib.toLower profile));
      bin =
        if (defaultBrowser { inherit browser profile; }) == "chrome" then
          "${google-chrome}/bin/google-chrome-stable"
        else
          "${chromium}/bin/chromium";
      preRemoveDefaultApplication = writeTextFile {
        name = "remove-default-app";
        executable = true;
        text = ''
          #!/usr/bin/env bash
          if [[ -z "${appId}" ]]; then
            exit 0
          fi
          find "$HOME/.local/share/applications/" -type f \
              -regex '.*/[cC]hrom\(e\|ium\)-${appId}-.*.desktop' -print0 | \
            xargs -0 -r rm -vf
        '';
      };
    in
    lib.concatStringsSep "\n" [
      (
        lib.concatStringsSep
          " "
          (
            [
              "makeWrapper"
              bin
              "$out/bin/${name}"
            ] ++ (
              [
                "--add-flags"
                "--gtk-version=4"
              ]
            ) ++ [
              "--add-flags"
              ("--user-data-dir=" + userDataDir)
              # "--add-flags" ("--class=" + mkWMClass { inherit browser profile appId; })
            ] ++ (
              (if (disableGPU) then [
                # TODO, remove when https://github.com/NixOS/nixpkgs/issues/244742 is fixed
                "--add-flags"
                "--disable-gpu"
              ] else [ ]) ++
              [
                "--add-flags"
                "--ozone-platform=wayland"
                "--add-flags"
                "--ozone-platform-hint=auto"
                "--add-flags"
                "--enable-wayland-ime"
              ]
            ) ++ (
              if (appId != null) then
                [ "--add-flags" "--app-id=${appId}" "--run" preRemoveDefaultApplication ]
              else [ ]
            ) ++ (
              if (overrideAppIcons && appId != null) then
                [ "--run" "$out/libexec/override-app-icon-${appId}" ]
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
        if (overrideAppIcons && appId != null) then
          ''
            if [[ ! -e "$out/libexec" ]]; then
              mkdir -pv "$out/libexec"
            fi
            {
              printf '#!/usr/bin/env bash\n';
              printf 'exec ${overrideAppIconsScript} "${appId}"'
              printf ' "%s/share/icons/hicolor" "${userDataDir}" "${pngname}"\n' "$out";
            } >"$out/libexec/override-app-icon-${appId}";
            chmod +x "$out/libexec/override-app-icon-${appId}"
          ''
        else ""
      )
    ];

  mkETHWrapper = { name, ... }@args: mkWrapper ({
    profile = workProfile;
    annotateWithETH = true;
  } // args);

  mkAdminWrapper = { name, ... }@args: mkWrapper ({
    profile = adminProfile;
    annotateWithETH = true;
  } // args);

  wrappers = [
    (mkWrapper {
      name = "chrome-private";
      browser = "chrome";
      longName = "Personal Chrome Browser";
    })
    (mkWrapper {
      name = "chromium-private";
      browser = "chromium";
      longName = "Personal Chromium Browser";
    })
    (mkWrapper {
      name = "feedly";
      longName = "Feedly";
      appId = "hipbfijinpcgfogaopmgehiegacbhmob";
      icon = "feedly.svg";
    })
    (mkWrapper {
      name = "gcontacts";
      longName = "Personal Google Contacts";
      appId = "pmcngklofgngifnoceehmchjlildnhkj";
      icon = "Google_Contacts_icon.svg";
    })
    (mkWrapper {
      name = "gdrive";
      longName = "Personal Google Drive";
      appId = "aghbiahbpaijignceidepookljebhfak";
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
      appId = "jneocipojkkahfcibhjaiilegofacenn";
      icon = "duo_bicep_curl.svg";
    })
    (mkWrapper {
      name = "gmaps";
      longName = "GMaps - Google Maps";
      appId = "mnhkaebcjjhencmpkapnbdaogjamfbcj";
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
      appId = "ncmjhecbjeaamljdfahankockkkdmedg";
      icon = "Google_Photos_icon.svg";
    })
    (mkWrapper {
      name = "whatsapp";
      longName = "Whatsapp";
      appId = "hnpfjngllnobngcgfapefoaidbinmjnm";
      icon = "WhatsApp.svg";
    })
    (mkWrapper {
      name = "youtube";
      longName = "Youtube";
      appId = "agimnkijcaahngcdmfeangaknmldooml";
      icon = "YouTube_social_white_squircle_2017.svg";
    })
    (mkWrapper {
      name = "ytmusic";
      longName = "Youtube Music";
      appId = "cinhimbnkkaeohfgghhklpknlkffjgod";
      icon = "Youtube_Music_logo.svg";
    })

    (mkETHWrapper {
      name = "chromium-work";
      longName = "ETH Chrome Browser";
      annotateWithETH = false;
    })
    (mkAdminWrapper {
      name = "chromium-admin";
      longName = "ETH Admin Chrome Browser";
      annotateWithETH = false;
    })
    (mkETHWrapper {
      name = "ethmail";
      longName = "ETH Outlook Email";
      icon = "Microsoft_Office_Outlook_2018–present.svg";
      appId = "ddeecgembbmgmafkbpdpmcciajppmkfo";
      overrideAppIcons = true;
    })
    (mkETHWrapper {
      name = "ethis";
      longName = "ETH IS SAP";
      icon = "sap-logo-png_2285421.png";
      appId = "dgojkhdanjeiakibdjeackdfbhkgapco";
      overrideAppIcons = true;
    })
    (mkETHWrapper {
      name = "ElemenTH";
      longName = "ETH Element";
      icon = "Element_software_logo.svg";
      appId = "hciogcoanhfdggodlgaednoijmjcmchh";
      overrideAppIcons = true;
    })
  ];
in
stdenv.mkDerivation {
  name = "chrome-wrappers";
  version = google-chrome.version;
  meta = google-chrome.meta;
  nativeBuildInputs = [ makeWrapper google-chrome imagemagick parallel bc ];
  buildInputs = [ moreutils jq ];
  runtimeDependencies = [ google-chrome chromium ];
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
