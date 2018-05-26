{ config, pkgs, ... }:

{
  myscript-package = pkgs.stdenv.mkDerivation {
    name = "cvim-server";
    buildInputs = [
      (pkgs.python36.withPackages (pythonPackages: with pythonPackages; [
        consul
        six
        requests2
      ]))
    ];
    src = fetchurl {
      url = "https://raw.githubusercontent.com/1995eaton/chromium-vim/1.2.99/cvim_server.py";
      #sha256 = "0wqd8sjmxfskrflaxywc7gqw7sfawrfvdxd9skxawzfgyy0pzdz6";
    };
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp ${./myscript.py} $out/bin/myscript
    '';
  };

  systemd.user.services.cvim-server = {
    enable = true;
    description = "Cvim server";
    after = ["network.target" "sound.target"];
    environment = {
      DISPLAY = ":0";
      PORT=8001
      EDITOR="nvim-qt --nofork"
    };

    serviceConfig = {
      PermissionsStartOnly = true;
      ExecStart = "${pkgs.cvim-server}/bin/cvim_server.py";
      Restart = "always";
      RestartSec = "2s";
    };
  };

}
