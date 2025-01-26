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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    authentik-nix.url = "github:nix-community/authentik-nix";
  };
  outputs = inputs@{ self, ... }: {
    nixosConfigurations = {
      michowps = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix

          inputs.authentik-nix.nixosModules.default
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
                host = "authentik.michojel.cz";
              };
            };
          }
        ];
      };
    };
  };
}
