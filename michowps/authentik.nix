{ config, lib, pkgs, ... }:

let
  authentik-version = "2025.2.4";
  authentik-nix-src = builtins.fetchTarball {
    url = "https://github.com/nix-community/authentik-nix/archive/version/${authentik-version}.tar.gz";
    sha256 = "15b9a2csd2m3vwhj3xc24nrqnj1hal60jrd69splln0ynbnd9ki4";
  };
  host = "authentik.michojel.cz";
  pkgs = import nixpkgs { system = system; };
in
{
  imports = [
    authentik-nix.nixosModules.default
  ];
  services.authentik = {
    enable = true;
    environmentFile = "/var/lib/private/authentik/authentik-env";
    settings = {
      email = {
        host = "smtp.protonmail.ch";
        port = 587;
        username = "admin@michojel.cz";
        use_tls = true;
        use_ssl = false;
        from = "admin@michojel.cz";
      };
      disable_startup_analytics = true;
      avatars = "initials";
    };

    nginx = {
      enable = true;
      enableACME = true;
      host = host;
    };
  };

  systemd.services.authentik = {
    # it takes a while before authentik becomes ready after systemd service reports "ready"
    # required at least for grist-server
    postStart = ''
      set -euo pipefail
      for ((i=0; i < 120; i++)); do
        ${pkgs.curl}/bin/curl --silent -I --fail https://${host} | head -n 1 && exit 0;
        sleep 0.5;
      done
      exit 1
    '';
  };
}
