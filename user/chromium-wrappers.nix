{ pkgs ? import <nixpkgs> {}, ... }:

with pkgs;
let
    dataDirBase    = "/home/miminar/.config/chromium";
    workProfile    = "RedHat";
    defaultWMClass = "Chromium";
in stdenv.mkDerivation {
  name = "chromium-wrappers";
  version = chromium.version;
  meta = chromium.meta;
  nativeBuildInputs = [makeWrapper chromium];
  runtimeDependencies = [chromium];
  phases = ["installPhase"];
  installPhase = ''
    function wrapChromiumProfile() {
      # Arguments:
      #  1st - wrapper name
      #  2nd - user data direcotory path
      #  3rd - (optional) WM class name suffix
      #  ... - (optional) any other flag will be treated as a general flag
      local wrappername="$1"
      local args=( --add-flags "--user-data-dir=$2")
      if [[ "$#" -gt 2 && -n "''${3:-}" ]]; then
        args+=( --add-flags "--class=${defaultWMClass}.$3" )
        shift
      fi
      while [[ "$#" -gt 2 ]]; do
        args+=( --add-flags "$3" )
        shift
      done
      makeWrapper "${chromium}/bin/chromium" "$out/bin/''${wrappername}" "''${args[@]}"
    }
    function wrapChromium() {
      # Arguments:
      #  1st - wrapper name
      #  2nd - (optional) chrome application id
      local wrappername="$1"
      shift
      local args=( "''${wrappername}" "${dataDirBase}" "" )
      if [[ "$#" -gt 0 ]]; then
        args+=( "--app-id=$1" )
        shift
      fi
      wrapChromiumProfile "''${args[@]}"
    }
    function wrapChromiumRH() {
      # Arguments:
      #  1st - wrapper name
      #  2nd - (optional) chrome application id
      local userdatadir="${dataDirBase}-${workProfile}"
      local wrappername="$1"
      shift
      local args=( "''${wrappername}" "''${userdatadir,,}" "redhat" )
      if [[ "$#" -gt 0 ]]; then
        args+=( "--app-id=$1" )
        shift
      fi
      # '--host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE 127.0.0.1"'
      args+=( '--auth-server-whitelist="*.redhat.com"' )
      wrapChromiumProfile "''${args[@]}"
    }

    wrapChromium chromium-private
    wrapChromium gcalendar kjbdgfilnfhdoflbpgamdcdgpehopbep
    wrapChromium gdocs     bojccfnmcnekjgjhcaklmcgofnngpjcl
    wrapChromium gsheets   lcahnhkcfaikkapifpaenbabamhfnecc
    wrapChromium gdrive    lkdnjjllhbbhgjfojnheoooeabjimbka
    wrapChromium duolingo  aiahmijlpehemcpleichkcokhegllfjl
    wrapChromium gmail     pjkljhegncpnkpknbcohdijeoejaedia
    wrapChromium gmaps     okmglncioejakncpbchjfnoingecodff
    wrapChromium mapy      mnadlckdoclecdmddabnbgjnkfoiddpd
    wrapChromium mega      ockmlcfhhimcljikencdeppnoljjjfjk
    wrapChromium gmessages hpfldicfbfomlpcikngkocigghgafkph
    wrapChromium skypeweb  bjdilgfelnbljgdpngladebaeggachpa
    wrapChromium whatsapp  hnpfjngllnobngcgfapefoaidbinmjnm

    wrapChromium wikics    enjdmlmicjdnokcbaeajgmnippjnkfmo
    wrapChromium wikide    bhdbngpdfcdnndblpfphbmkajcbpnean
    wrapChromium wikien    mopbmgngnfadcehgbmkgjblgbhiehmlm
    wrapChromium wikiru    oenmclfdgkfbfladdhglinfmbbgnljhj

    wrapChromium wireweb   kfhkficiiapojlgcnbkgacfjmpffgoki
    wrapChromium youtube   blpcfgokakmgnkcojhhkbfbldkacnbeo
    wrapChromium ytmusic   eeaafbmfeofhhjpjklgoobllogkjdgap

    userdatadir="${dataDirBase}-${workProfile}"
    wrapChromiumRH chromium-work
    wrapChromiumRH ibmbox      gckfeldgkmajgieiakjfpmoahpajonjg
    wrapChromiumRH rhgcalendar kjbdgfilnfhdoflbpgamdcdgpehopbep
    wrapChromiumRH rhgchat     pommaclcbfghclhalboakcipcmmndhcj
    wrapChromiumRH rhgmessages kpbdgbekoclglmjckpbanehbpjnlphkf
    wrapChromiumRH rhgdocs     gcefppfnjnmndpknenooeofkfcbakpkp
    wrapChromiumRH rhgdrive    lkdnjjllhbbhgjfojnheoooeabjimbka
    wrapChromiumRH rhgmail     nkcknjnfmnmjahcahhhjgakeikoiomof
    wrapChromiumRH rhgsheets   albjknpbljlpmmpfjicdohagjcifagdi
    wrapChromiumRH sapcalendar oeogacjkgmanlfjadbnhngnpbkibgfhj
    wrapChromiumRH sapmail     plnbadkpncgbnekpephdpooeafambhak
    wrapChromiumRH sapdrive    phgkmbchjgnehfpnmbekcoclneeojdma

    # TODO: create desktop shortcuts
    #  #!/nix/store/r8x2fx08nkka2n6ikrlnfz2z8r0b6gb0-xdg-utils-1.1.2/bin/xdg-open
    #  [Desktop Entry]
    #  Version=1.0
    #  Terminal=false
    #  Type=Application
    #  Name=Wire
    #  Exec=/nix/store/iw0bbvfn8w12a1mfpl878faylz3girm5-chromium-71.0.3578.98/libexec/chromium/chromium --user-data-dir=/home/miminar/.config/chromium --profile-directory=Default --app-id=kfhkficiiapojlgcnbkgacfjmpffgoki
    #  Icon=chrome-kfhkficiiapojlgcnbkgacfjmpffgoki-Default
    #  StartupWMClass=crx_kfhkficiiapojlgcnbkgacfjmpffgoki
  '';
}
