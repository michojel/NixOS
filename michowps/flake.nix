{
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    authentik-nix.url = "github:nix-community/authentik-nix";
  };
  outputs = inputs@{ self, nixpkgs, ... }:
    {
      nixosConfigurations = {
        michowps = inputs.nixpkgs.lib.nixosSystem (
          let
            system = "x86_64-linux";
          in
          {
            system = system;
            modules = [
              ./configuration.nix

              inputs.authentik-nix.nixosModules.default
              (
                let
                  host = "authentik.michojel.cz";
                  pkgs = import nixpkgs { system = system; };
                in
                {
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
              )
            ];
          }
        );
      };
    };
}
