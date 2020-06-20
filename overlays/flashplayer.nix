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
        version = "32.0.0.387";
      in {
        version = version;
        name = "flashplayer-${version}";
        src = super.fetchurl {
          url = let
            arch =
              if super.stdenv.hostPlatform.system == "x86_64-linux" then
                "x86_64"
              else if super.stdenv.hostPlatform.system == "i686-linux" then
                "i386"
              else throw "Flash Player is not supported on this platform";
          in
            "https://fpdownload.adobe.com/get/flashplayer/pdc/${version}/flash_player_npapi_linux.${arch}.tar.gz";
          sha256 = "0si8rx955kyfsprk5465hfzafxvrdm7g686q7p5xykmh88nck6k2";
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
