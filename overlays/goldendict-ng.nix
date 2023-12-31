self: super:
let
  version = "v23.12.07-HeavySnow.b0086d5c";
in
{
  goldendict-ng = super.goldendict-ng.overrideAttrs (
    attrs: {
      version = version;

      src = super.fetchFromGitHub {
        owner = "xiaoyifang";
        repo = "goldendict-ng";
        rev = "${version}";
        sha256 = "sha256-GAcm8XhPZ+knz1jmLMzQo+52r745AFx6rLlX4dMSXGs=";
        fetchSubmodules = true;
      };
    }
  );
}
