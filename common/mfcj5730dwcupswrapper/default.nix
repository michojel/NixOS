{ coreutils
, dpkg
, fetchurl
, gnugrep
, gnused
, makeWrapper
, mfcj5730dwlpr
, perl
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "mfcj5730dwcupswrapper";
  version = "1.0.1-0";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103041/${pname}-${version}.i386.deb";
    sha256 = "1kph0l8aadnld0r0576w5k5mbn3qpp7kl986f3gw8myrcfkad02x";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  phases = [ "installPhase" ];

  installPhase = ''
    dpkg-deb -x $src $out

    basedir=${mfcj5730dwlpr}/opt/brother/Printers/mfcj5730dw
    dir=$out/opt/brother/Printers/mfcj5730dw

    substituteInPlace $dir/cupswrapper/brother_lpdwrapper_mfcj5730dw \
      --replace /usr/bin/perl ${perl}/bin/perl \
      --replace "basedir =~" "basedir = \"$basedir/\"; #" \
      --replace "PRINTER =~" "PRINTER = \"mfcj5730dw\"; #"

    wrapProgram $dir/cupswrapper/brother_lpdwrapper_mfcj5730dw \
      --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep gnused ]}

    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model

    ln $dir/cupswrapper/brother_lpdwrapper_mfcj5730dw $out/lib/cups/filter
    ln $dir/cupswrapper/brother_mfcj5730dw_printer_en.ppd $out/share/cups/model
  '';

  meta = {
    description = "Brother MFC-J5730DW CUPS wrapper driver";
    homepage = http://www.brother.com/;
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.michojel ];
  };
}
