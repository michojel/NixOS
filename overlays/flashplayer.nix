# To update:
#   1. visit https://get.adobe.com/cz/flashplayer/
#   2. copy the version string to the version attribute down below
#   3. run nix-prefetch-url --unpack https://fpdownload.adobe.com/get/flashplayer/pdc/${version}/flash_player_npapi_linux.$(uname -m).tar.gz
#   4. update the sha256 field
# TODO: automate this
self: super: {
  flashplayer = super.flashplayer.overrideDerivation (
    oldAttrs:
    let
      version = "32.0.0.433";
    in
    {
      version = version;
      name = "flashplayer-${version}";
      src = super.fetchurl {
        url =
          let
            arch =
              if super.stdenv.hostPlatform.system == "x86_64-linux" then
                "x86_64"
              else if super.stdenv.hostPlatform.system == "i686-linux" then
                "i386"
              else throw "Flash Player is not supported on this platform";
          in
          "https://fpdownload.adobe.com/get/flashplayer/pdc/${version}/flash_player_npapi_linux.${arch}.tar.gz";
          sha256 = "0k80i98zkpf6r46y1aw2zg1dsgbirg6rc8q21vycpvln395jq0pf";
      };
    }
  );

  #  firefox = super.firefox.override {
  #    flashplayer = flashplayer;
  #  };
  #  firefox-esr = super.firefox.override {
  #    flashplayer = flashplayer;
  #  };
  #
  #  #  firefoxPackages.firefox = super.firefoxPackages.firefox.override {
  #  #    flashplayer = flashplayer;
  #  #  };
  #  firefoxPackages.firefox = super.firefoxPackages.firefox.override {
  #    flashplayer = flashplayer;
  #  };
  #  firefoxPackages.firefox-esr-68 = super.firefoxPackages.firefox-esr-68.override {
  #    flashplayer = flashplayer;
  #  };
}
