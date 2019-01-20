{lib, pkgs, ... }:

# TODO: make this work
# inspired by http://stesie.github.io/2018/09/nixos-custom-keyboard-layout-revisited
pkgs.xorg // rec {
  xkeyboardconfig_vok = pkgs.xorg.xkeyboardconfig.overrideAttrs (attrs: {
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

  xorgserver = pkgs.xorg.xorgserver.overrideAttrs (old: {
    configureFlags = old.configureFlags ++ [
      "--with-xkb-bin-directory=${xkbcomp}/bin"
      "--with-xkb-path=${xkeyboardconfig_vok}/share/X11/xkb"
    ];
  });

  setxkbmap = pkgs.xorg.setxkbmap.overrideAttrs (old: {
    runtimeDependencies = (lib.attrByPath ["runtimeDependencies" ] [] old)
      ++ [xkeyboardconfig_vok];
    buildInputs = old.buildInputs ++ [xkeyboardconfig_vok];
    postInstall =
      ''
        mkdir -p $out/share
        ln -sfn ${xkeyboardconfig_vok}/etc/X11 $out/share/X11
      '';
  });

  xkbcomp = pkgs.xorg.xkbcomp.overrideAttrs (old: {
    runtimeDependencies = (lib.attrByPath ["runtimeDependencies"] [] old)
      ++ [xkeyboardconfig_vok];
    buildInputs = old.buildInputs ++ [xkeyboardconfig_vok];
    configureFlags = "--with-xkb-config-root=${xkeyboardconfig_vok}/share/X11/xkb";
  });
}

# ex: et ts=2 sw=2 :
