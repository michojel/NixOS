{ stdenv
, lib
, semeru-bin-8
, fetchurl
, fontDirectories
, imake
, libjpeg
, libXaw
, libXmu
, libXpm
, makeWrapper
, openssh
, openssl
, perl
, perlPackages
, samba     # smbclient
, stunnel
, tcl
, tk        # wish
, xauth
, xorg
, zlib
}:
let
  pname = "ssvnc";
  version = "1.0.29";
in
stdenv.mkDerivation {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://downloads.sf.net/sourceforge/${pname}/${pname}-${version}.src.tar.gz";
    sha256 = "13b1gmaprznkd171vgiwgxy62m11wkmk58lkjryb0s5aivmk5pvl";
  };

  patches = [ ./ssvnc-openssl1.1.patch ];

  postPatch = ''
    substituteInPlace scripts/util/ss_vncviewer --replace /usr/bin/perl "${perl}/bin/perl" 
  '';

  # for the builder script
  inherit fontDirectories;

  hardeningDisable = [ "format" ];

  buildInputs = [
    semeru-bin-8 # jar and javac
    imake
    libjpeg
    libXaw
    libXmu
    libXpm
    makeWrapper
    openssh
    openssl
    perl
    stunnel
    tcl
    tk
    xauth
    zlib
    xorg.libX11
    xorg.libXtst
    xorg.libSM
    xorg.libXext
  ];

  propagatedBuildInputs = [ ];

  runtimeDependencies = [ perlPackages.IOSocketInet6 ];

  makeFlags = [ "PREFIX=$(out)" ];
  postFixup = ''
      #sed -i -e '1c#!${tk}/bin/wish' "$out/bin/sc_remote"
      for cmd in $out/bin/*; do
        wrapProgram "$cmd" --prefix PATH : "${lib.makeBinPath [
      semeru-bin-8
      openssh
      samba
      stunnel
      tk
    ]}"
      done
  '';

  meta = {
    license = lib.licenses.gpl2;
    homepage = http://www.karlrunge.com/x11vnc/ssvnc.html;
    description = "SSL/SSH VNC viewer";

    longDescription = ''
      The Enhanced TightVNC Viewer, SSVNC, adds encryption security to VNC connections.
    '';

    maintainers = [ lib.maintainers.michojel ];
    platforms = lib.platforms.unix;
  };
}
