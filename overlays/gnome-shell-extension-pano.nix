self: super:

let
  pname = "gnome-shell-extension-pano";
  version = "9";
  uuid = "pano@elhan.io";

  girpathsPatch = (super.substituteAll {
    src = ./deps/gnome-shell-extensions/pano/set-dirpaths.patch;
    gda_path = "${super.libgda}/lib/girepository-1.0";
    gsound_path = "${super.gsound}/lib/girepository-1.0";
  });

  panoSource = super.fetchFromGitHub {
    owner = "oae";
    repo = "gnome-shell-pano";
    rev = "v${version}";
    hash = "sha256-cn6+A6sAQyUfwKGQIOFTGrimvZ6fsBstcJ4I6AAk31A=";
  };

  yarnNix = super.stdenv.mkDerivation {
    inherit pname version;
    name = "gnome-shell-extension-pano-yarn-nix-${version}";
    src = panoSource;

    nativeBuildInputs = with super; [
      yarn2nix
    ];

    buildPhase = ''
      yarn2nix >yarn.nix
    '';

    installPhase = ''
      mkdir -p "$out"
      cp -p package.json yarn.lock yarn.nix "$out/"
    '';
  };
in
{
  gnomeExtensions = super.gnomeExtensions // {
    pano = super.stdenv.mkDerivation rec {
      inherit pname version;

      src = panoSource;

      nativeBuildInputs = with super; [
        nodePackages.rollup
        nodePackages.yarn
      ];

      buildInputs = with super; [
        atk
        cogl
        glib
        gsound
        gnome.gnome-shell
        gnome.mutter
        gtk3
        libgda
        pango
      ];

      nodeModules = super.mkYarnModules {
        inherit pname version; # it is vitally important the the package.json has name and version fields
        name = "gnome-shell-extension-pano-modules-${version}";
        packageJSON = "${yarnNix}/package.json";
        yarnLock = "${yarnNix}/yarn.lock";
        yarnNix = "${yarnNix}/yarn.nix";
      };

      patches =
        let
          dataDirPaths = super.lib.concatStringsSep ":" [
            "${super.atk.dev}/share/gir-1.0"
            "${super.gsound}/share/gir-1.0"
            "${super.gnome.gnome-shell}/share/gnome-shell"
            "${super.gnome.mutter}/lib/mutter-10"
            "${super.gtk3.dev}/share/gir-1.0"
            "${super.libgda}/share/gir-1.0"
            "${super.pango.dev}/share/gir-1.0"
          ];
        in
        [
          (super.substituteAll {
            src = ./deps/gnome-shell-extensions/pano/xdg_data_dirs.patch;
            xdg_data_dirs = "${dataDirPaths}";
          })
        ];

      postPatch = ''
        substituteInPlace resources/metadata.json \
          --replace '"version": 999' '"version": ${version}' 
      '';

      buildPhase = ''
        runHook preBuild

        ln -sv "${nodeModules}/node_modules" node_modules
        yarn build
        patch --verbose -d dist -p1 < ${girpathsPatch}

        runHook postBuild
      '';

      passthru = {
        extensionUuid = uuid;
        extensionPortalSlug = "pano";
      };

      installPhase = ''
        runHook preInstall
        mkdir -p "$out/share/gnome-shell/extensions/${uuid}"
        cp -r dist/* "$out/share/gnome-shell/extensions/${uuid}/"
        runHook postInstall
      '';

      meta = with super.lib; {
        description = "Next-gen Clipboard Manager for Gnome Shell";
        license = licenses.gpl2Only;
        platforms = platforms.linux;
        maintainers = [ maintainers.michojel ];
        homepage = "https://github.com/oae/gnome-shell-pano";
      };
    };
  };
}

