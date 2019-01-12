{config, lib, pkgs, ... }:

rec {
  xorg = pkgs.xorg // rec {
    xkeyboardconfig_vok = pkgs.xorg.xkeyboardconfig_vok.overrideAttrs (attrs: {
          srcs = [attrs.src (pkgs.fetchFromGitLab {
            owner = "vojta_vogo";
            repo = "vok";
            rev = "9b338e5c8859830e09157e5e70498f65f980e3b2";
            sha256 = "1mz5dpizlkz858nv41dsi9idd7m9a4jgbwgld6lwklmaxg8qmadi";
          })];
      #sourceRoot = attrs.name;
      postInstall = attrs.postInstall + ''
        install -m 0644 "xorg/vok" "$out/share/X11/xkb/symbols"
      '';
    });

    xorgserver = pkgs.xorg.xorgserver.overrideAttrs (old: {
      configureFlags = old.configureFlags ++ [
        "--with-xkb-bin-directory=${xkbcomp}/bin"
        "--with-xkb-path=${xkeyboardconfig_vok}/share/X11/xkb"
      ];
    }); 

    setxkbmap = pkgs.xorg.setxkbmap.overrideAttrs (old: {
      postInstall =
        ''
          mkdir -p $out/share
          ln -sfn ${xkeyboardconfig_vok}/etc/X11 $out/share/X11
        '';
    });

    xkbcomp = pkgs.xorg.xkbcomp.overrideAttrs (old: {
      configureFlags = "--with-xkb-config-root=${xkeyboardconfig_vok}/share/X11/xkb";
    });
  };

  xkbvalidate = pkgs.xkbvalidate.override {
    libxkbcommon = pkgs.libxkbcommon.override {
      xkeyboard_config = xorg.xkeyboardconfig_vok;
    };
  };
}

# ex: et ts=2 sw=2 :
