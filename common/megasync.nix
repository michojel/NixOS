{ stdenv
, autoconf
, automake
, bash
, bashInteractive
, c-ares
, cryptopp
, curl
, doxygen
, freeimage
, fetchFromGitHub
, hicolor-icon-theme
, libmediainfo
, libraw
, libsodium
, libtool
, libuv
, libzen
, lsb-release
, makeDesktopItem
, pkgconfig
, qt5
, sqlite
, swig
, unzip
, wget 
, enableFFmpeg   ? false, ffmpeg  ? null
# TODO: verify whether ply is needed
# TODO: how to enable python3?
, pythonBindings ? false, python  ? null, ply      ? null
# TODO: verify whether all are needed
# TODO: does not work at all (neither readline nor termcap found)
, enableTermcap  ? false, ncurses ? null, readline ? null, gpm ? null
}:

assert pythonBindings -> python != null && ply     != null;
assert enableTermcap  -> gpm    != null && ncurses != null && readline != null;

stdenv.mkDerivation rec {
  name = "megasync-${version}";
  version = "4.1.1.0";

  src = fetchFromGitHub {
    owner = "meganz";
    repo = "MEGAsync";
    rev = "v${version}_Linux";
    sha256 = "0lc228q3s9xp78dxjn22g6anqlsy1hi7a6yfs4q3l6gyfc3qcxl2";
    fetchSubmodules = true;
  };
  
  desktopItem = makeDesktopItem {
    name = "megasync";
    exec = "megasync";
    icon = "megasync";
    comment = meta.description;
    desktopName = "MEGASync";
    genericName = "File Synchronizer";
    categories = "Network;FileTransfer;";
    startupNotify = "false";
  };

  nativeBuildInputs = [ 
    doxygen
    libsodium
    lsb-release
    qt5.qmake
    qt5.qttools
    swig
  ];
  buildInputs = [ 
    autoconf
    automake
    bash
    c-ares
    cryptopp
    curl
    freeimage
    hicolor-icon-theme
    libmediainfo
    libraw
    libtool
    libuv
    libzen
    pkgconfig
    qt5.qtbase
    qt5.qtsvg
    sqlite
    unzip
    wget 
  ] ++ stdenv.lib.optionals pythonBindings [ ply python ]
    ++ stdenv.lib.optionals enableFFmpeg   [ ffmpeg ]
    ++ stdenv.lib.optionals enableTermcap  [ gpm ncurses readline ];
  
  patchPhase = ''
    for file in $(find src/ -type f \( -iname configure -o -iname \*.sh  \) ); do
      substituteInPlace "$file" \
        --replace "/bin/bash" "${bashInteractive}/bin/bash"
    done
  '';
  
  configurePhase = ''
    cd src/MEGASync/mega
    ./autogen.sh
    ./configure \
        --disable-examples \
        --disable-java \
        --disable-php \
        --enable-chat \
        --enable-python \
        --with-cares \
        --with-cryptopp \
        --with-curl \
        --with-ffmpeg \
        --with-freeimage \
        --with-sodium \
        --with-sqlite \
        --with-termcap \
        --with-zlib
    cd ../..
  '';
  
  buildPhase = ''
    qmake CONFIG+="release" MEGA.pro
    lrelease MEGASync/MEGASync.pro
    make -j $NIX_BUILD_CORES
  '';
  
  # TODO: install bindings
  installPhase = ''
    mkdir -p $out/share/icons
    install -Dm 755 MEGASync/megasync $out/bin/megasync
    cp -r ${desktopItem}/share/applications $out/share
    cp MEGASync/gui/images/uptodate.svg $out/share/icons/megasync.svg
  '';

  meta = with stdenv.lib; {
    description = "Easy automated syncing between your computers and your MEGA Cloud Drive";
    homepage    = https://mega.nz/;
    license     = licenses.free;
    platforms   = [ "i686-linux" "x86_64-linux" ];
  };
}
