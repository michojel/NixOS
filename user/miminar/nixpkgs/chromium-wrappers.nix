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
      #  3rd - chrome application id
      #  4th - (optional) WM class name suffix
      args=( --add-flags "--user-data-dir=$2" --add-flags "--app-id=$3" )
      if [[ "$#" -gt 3 ]]; then
        args+=( --add-flags "--class=${defaultWMClass}.$4" )
      fi
      makeWrapper "${chromium}/bin/chromium" "$out/bin/$1" "''${args[@]}"
    }
    function wrapChromium() {
      # Arguments:
      #  1st - wrapper name
      #  2nd - chrome application id
      wrapChromiumProfile "$1" "${dataDirBase}" "$2"
    }
    function wrapChromiumRH() {
      # Arguments:
      #  1st - wrapper name
      #  2nd - chrome application id
      local userdatadir="${dataDirBase}-${workProfile}"
      wrapChromiumProfile "$1" "''${userdatadir,,}" "$2" "redhat"
    }

    wrapChromium calendar kjbdgfilnfhdoflbpgamdcdgpehopbep
    wrapChromium gdocs bojccfnmcnekjgjhcaklmcgofnngpjcl
    wrapChromium gsheets lcahnhkcfaikkapifpaenbabamhfnecc
    wrapChromium gdrive lkdnjjllhbbhgjfojnheoooeabjimbka
    wrapChromium duolingo aiahmijlpehemcpleichkcokhegllfjl
    wrapChromium gmail pjkljhegncpnkpknbcohdijeoejaedia
    wrapChromium gmaps ejidjjhkpiempkbhmpbfngldlkglhimk
    wrapChromium skype bjdilgfelnbljgdpngladebaeggachpa
    wrapChromium whatsapp hnpfjngllnobngcgfapefoaidbinmjnm
    wrapChromium wireweb kfhkficiiapojlgcnbkgacfjmpffgoki
    wrapChromium youtube blpcfgokakmgnkcojhhkbfbldkacnbeo

    wrapChromiumRH rhcalendar kjbdgfilnfhdoflbpgamdcdgpehopbep
    wrapChromiumRH rhchat pommaclcbfghclhalboakcipcmmndhcj
    wrapChromiumRH rhgdocs gcefppfnjnmndpknenooeofkfcbakpkp
    wrapChromiumRH rhdrive lkdnjjllhbbhgjfojnheoooeabjimbka
    wrapChromiumRH rhgmail nkcknjnfmnmjahcahhhjgakeikoiomof
    wrapChromiumRH rhgsheets albjknpbljlpmmpfjicdohagjcifagdi
    wrapChromiumRH sapmail plnbadkpncgbnekpephdpooeafambhak

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
