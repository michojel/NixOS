{pkgs, ... }:

# TODO: make this work
{
  xkeyboardconfig = pkgs.xorg.xkeyboardconfig.overrideAttrs (attrs: {
        srcs = [attrs.src (pkgs.fetchFromGitLab {
          owner = "vojta_vogo";
          repo = "vok";
          rev = "9b338e5c8859830e09157e5e70498f65f980e3b2";
          sha256 = "1mz5dpizlkz858nv41dsi9idd7m9a4jgbwgld6lwklmaxg8qmadi";
        })];
    name = "xkeyboardconfig_vok";
    sourceRoot = attrs.name;
    postInstall = attrs.postInstall + ''
      install -m 0644 "../source/xorg/vok" "$out/share/X11/xkb/symbols"
    '';
  });
}

# ex: et ts=2 sw=2 :
