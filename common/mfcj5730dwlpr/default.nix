{ coreutils
, dpkg
, fetchurl
, file
, ghostscript
, gnugrep
, gnused
, makeWrapper
, perl
, pkgs
, stdenv
, which
}:

stdenv.mkDerivation rec {
  pname = "mfcj5730dwlpr";
  version = "1.0.1-0";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103017/${pname}-${version}.i386.deb";
    sha256 = "0k83y8kw03i7sqzjy04xs3csgnjmgcmfar94mabjvwsrq1lz6r29";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  phases = [ "installPhase" ];

  installPhase = ''
    dpkg-deb -x $src $out

    dir=$out/opt/brother/Printers/mfcj5730dw
    filter=$dir/lpd/filter_mfcj5730dw

    substituteInPlace $filter \
      --replace /usr/bin/perl ${perl}/bin/perl \
      --replace "BR_PRT_PATH =~" "BR_PRT_PATH = \"$dir/\"; #" \
      --replace "PRINTER =~" "PRINTER = \"mfcj5730dw\"; #"

    wrapProgram $filter \
      --prefix PATH : ${stdenv.lib.makeBinPath [
    coreutils
    file
    ghostscript
    gnugrep
    gnused
    which
  ]}

    # need to use i686 glibc here, these are 32bit proprietary binaries
    interpreter=${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2
    patchelf --set-interpreter "$interpreter" $dir/lpd/brmfcj5730dwfilter
  '';

  meta = {
    description = "Brother MFC-L8690CDW LPR printer driver";
    homepage = http://www.brother.com/;
    license = stdenv.lib.licenses.unfree;
    maintainers = [ stdenv.lib.maintainers.michojel ];
    #platforms = [ "i686-linux" ];
    platforms = stdenv.lib.platforms.linux;
  };
}
