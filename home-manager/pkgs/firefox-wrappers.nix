{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;
let
  workProfile = "ondat";
  defaultProfile = "private";
  defaultWMClass = "Firefox";
  defaultIcons = {
    private = "Firefox-logo.svg";
    redhat = "rht-firefox.svg";
  };
  hatIcon = "Red Hat-scaled.svg";
  defaultIcon = { profile ? "private", icon ? null }:
    let
      p = if profile == null then "private" else profile;
    in
    (if icon == null then defaultIcons."${p}" else icon);

  mkWMClass = { profile ? null }: (
    "${defaultWMClass}" + (lib.optionalString (profile != null) ("." + lib.toLower profile))
  );

  mkDesktopItem =
    { name
    , profile ? defaultProfile
      # the suffix of the first item of WM_CLASS when running xprop on the window (without the crx_ prefix)
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
        icon = icon;
        exec = name;
        categories = if (categories != null) then categories else [ "Network" "WebBrowser" ];
        mimeTypes = mimeTypes;
        startupNotify = true;
        startupWMClass = mkWMClass { inherit profile; };
      }
    );

  cnvFunc = ''
    function cnv() {
      local size="$1"
      local srcFN="$2"
      local dest="$3"
      local addHat="$4"
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

      if [[ "$addHat" =~ ^(1|[tT]rue|[yY]es) ]]; then
        convertArgs=( -gravity SouthEast \
                      -resize $((size*4/5))x$((size*4/5)) -extent "$geom"
                      \( "chrome-wrappers/${hatIcon}" \
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
    , profile ? defaultProfile
    , icon ? null
    , annotateWithHat ? false
    , longName ? null
    , description ? null
    , comment ? null
    , categories ? null
    , mimeTypes ? [ ]
      # TODO
    , overrideAppIcons ? false
    }:
    let
      addHat = icon != null && annotateWithHat;
      icon_ = defaultIcon { inherit profile icon; };
      pngname = lib.replaceStrings
        [ ".svg" ]
        [ ((lib.optionalString addHat "-with-hat") + ".png") ]
        icon_;
      desktopItem = mkDesktopItem {
        inherit name profile longName description comment categories mimeTypes;
        icon = pngname;
      };
    in
    lib.concatStringsSep "\n" [
      (
        lib.concatStringsSep
          " "
          (
            [
              "makeWrapper"
              "${firefox}/bin/firefox"
              "$out/bin/${name}"
              "--add-flags"
              "-P"
              "--add-flags"
              profile
              "--add-flags"
              ("--class=" + mkWMClass { inherit profile; })
            ]
          )
      )

      ''
        pushd ${desktopItem}
          find "share/applications" -type f | xargs -i ln -v -s "${desktopItem}/{}" "$out/{}"
        popd

        addHat=${if addHat then "1" else "0"};
        dest="$out/share/icons/${pngname}"
        if [[ ! -e "''$dest" ]]; then
          parallel "''${parargs[@]}" cnv 128 "${icon_}" "$dest" "$addHat" -verbose
        fi

        for size in 16 24 32 48 64 72 96 128 192 256 512 1024; do
          dest="$out/share/icons/hicolor/''${size}x''${size}/apps/${pngname}"
          [[ -e "$dest" ]] && continue
          mkdir -p "$(dirname "$dest")"
          parallel "''${parargs[@]}" cnv "$size" "${icon_}" "$dest" "$addHat"
        done
      ''
    ];

  mkRHTWrapper = { name, ... }@args: mkWrapper ({ profile = workProfile; annotateWithHat = true; } // args);

  wrappers = [
    (mkWrapper {
      name = "firefox-private";
      longName = "Personal Firefox Browser";
    })

    (mkRHTWrapper {
      name = "firefox-work";
      profile = "redhat";
      longName = "RHT Firefox Browser";
      annotateWithHat = false;
    })
  ];
in
stdenv.mkDerivation {
  name = "firefox-wrappers";
  version = firefox.version;
  meta = firefox.meta;
  nativeBuildInputs = [ makeWrapper firefox imagemagick parallel bc ];
  buildInputs = [ moreutils jq ];
  runtimeDependencies = [ firefox kerberos ];
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
      mkdir -p $out/share/applications $out/share/icons $out/share/firefox-wrappers
    ''
    cnvFunc
    (lib.concatStringsSep "\n" wrappers)
    ''
      parallel --will-cite --semaphore --wait --id=convert
    ''
  ];
}
